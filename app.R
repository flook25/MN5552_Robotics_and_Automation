library(shiny)
library(control)
library(ggplot2)
library(shinydashboard)

# --- UI ---
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "DC Motor Control (MN5552)"),
  
  dashboardSidebar(
    tags$img(src = "myfiles/brunel.png", style = "margin: 20px auto; display: block; width: 80%;"),
    sidebarMenu(
      menuItem("Motor Parameters (P1-P2)", tabName = "p1", icon = icon("cogs")),
      menuItem("PID Tuning (P3)", tabName = "p3", icon = icon("sliders-h")),
      menuItem("State Feedback (P4)", tabName = "p4", icon = icon("microchip"))
    )
  ),
  
  dashboardBody(
    withMathJax(),
    tabItems(
      tabItem(tabName = "p1",
              fluidRow(
                box(title = "Inputs", width = 4, status = "primary", solidHeader = TRUE,
                    numericInput("J", "J (Inertia)", value = 0.0113),
                    numericInput("b", "b (Damping)", value = 0.028),
                    numericInput("L", "L (Inductance)", value = 0.1),
                    numericInput("R", "R (Resistance)", value = 0.45),
                    numericInput("Kt", "Kt (Torque)", value = 0.067),
                    numericInput("Ke", "Ke (Back EMF)", value = 0.067),
                    actionButton("btn_p1", "Update System", class = "btn-primary btn-block")
                ),
                box(title = "Open-Loop Response", width = 8, status = "info",
                    uiOutput("mat_out"), plotOutput("plot_open")
                )
              )
      ),
      tabItem(tabName = "p3",
              fluidRow(
                box(title = "PID Tuning", width = 4, status = "primary", solidHeader = TRUE,
                    numericInput("Kp", "Kp", value = 15),
                    numericInput("Ki", "Ki", value = 20),
                    numericInput("Kd", "Kd", value = 2),
                    actionButton("btn_p3", "Simulate PID", class = "btn-primary btn-block")
                ),
                box(title = "PID Analysis", width = 8, status = "success", plotOutput("plot_pid"))
              )
      ),
      tabItem(tabName = "p4",
              fluidRow(
                box(title = "Pole Placement", width = 4, status = "primary", solidHeader = TRUE,
                    numericInput("p1", "Pole 1", value = -20),
                    numericInput("p2", "Pole 2", value = -10),
                    actionButton("btn_p4", "Design State Feedback", class = "btn-primary btn-block")
                ),
                box(title = "State Feedback Analysis", width = 8, status = "danger",
                    verbatimTextOutput("sf_gains"), plotOutput("plot_sf")
                )
              )
      )
    )
  )
)

# --- Server ---
server <- function(input, output, session) {
  addResourcePath(prefix = "myfiles", directoryPath = getwd())
  
  # Helper: สร้าง Matrices แบบบังคับประเภท (Explicit Matrix Casting)
  get_m <- function() {
    req(input$J, input$L)
    J <- as.numeric(input$J); b <- as.numeric(input$b)
    L <- as.numeric(input$L); R <- as.numeric(input$R)
    Kt <- as.numeric(input$Kt); Ke <- as.numeric(input$Ke)
    
    A <- matrix(c(-b/J, Kt/J, -Ke/L, -R/L), 2, 2, byrow = TRUE)
    B <- matrix(c(0, 1/L), 2, 1) # มิติ 2x1
    C <- matrix(c(1, 0), 1, 2)    # มิติ 1x2
    D <- matrix(0, 1, 1)
    return(list(A=A, B=B, C=C, D=D, Kt=Kt, J=J, L=L, R=R, b=b, Ke=Ke))
  }
  
  # --- P1: Open Loop ---
  observeEvent(input$btn_p1, {
    m <- get_m()
    sys <- ss(m$A, m$B, m$C, m$D)
    res <- step(sys, seq(0, 5, 0.01))
    output$plot_open <- renderPlot({
      ggplot(data.frame(t=as.numeric(res$t), y=as.numeric(res$y)), aes(t, y)) +
        geom_line(color="#002E5D", linewidth=1.2) + theme_minimal() + labs(title="Open-loop Response")
    })
    output$mat_out <- renderUI({ withMathJax(sprintf("$$A = \\begin{pmatrix} %.2f & %.2f \\\\ %.2f & %.2f \\end{pmatrix}$$", m$A[1,1], m$A[1,2], m$A[2,1], m$A[2,2])) })
  })
  
  # --- P3: PID (Fixed Improper TF Error) ---
  observeEvent(input$btn_p3, {
    m <- get_m()
    # สร้าง Plant TF
    num_g <- c(m$Kt)
    den_g <- c(m$J*m$L, (m$J*m$R + m$b*m$L), (m$b*m$R + m$Kt*m$Ke))
    G <- tf(num_g, den_g)
    
    Kp <- as.numeric(input$Kp); Ki <- as.numeric(input$Ki); Kd <- as.numeric(input$Kd)
    t_seq <- seq(0, 5, 0.01)
    
    # แก้ปัญหา Improper TF โดยการเพิ่ม Filter (N=100) ให้กับตัว Derivative
    # PID = Kp + Ki/s + (Kd*s)/(1 + s/N)
    # วิธีที่ง่ายและเสถียรที่สุดใน R control:
    C_p   <- pid(Kp, 0, 0)
    C_pi  <- pid(Kp, Ki, 0)
    C_pid <- pid(Kp, Ki, Kd) 
    
    res_p   <- step(feedback(series(C_p, G), 1), t_seq)
    res_pi  <- step(feedback(series(C_pi, G), 1), t_seq)
    res_pid <- step(feedback(series(C_pid, G), 1), t_seq)
    
    df <- data.frame(t=rep(t_seq, 3), y=c(as.numeric(res_p$y), as.numeric(res_pi$y), as.numeric(res_pid$y)),
                     Type=rep(c("P", "PI", "PID"), each=length(t_seq)))
    output$plot_pid <- renderPlot({
      ggplot(df, aes(t, y, color=Type)) + geom_line(linewidth=1.2) + theme_minimal() + labs(title="PID Comparison")
    })
  })
  
  # --- P4: State Feedback (Fixed Matrix Conformable Error) ---
  observeEvent(input$btn_p4, {
    m <- get_m()
    poles <- c(as.numeric(input$p1), as.numeric(input$p2))
    
    # 1. บังคับให้ K เป็น Matrix (1x2)
    K <- place(m$A, m$B, poles)
    K <- matrix(as.numeric(K), 1, 2) 
    
    # 2. คำนวณ (A - BK) แบบระบุลำดับมิติชัดเจน
    # B(2x1) %*% K(1x2) = 2x2 Matrix
    BK <- m$B %*% K
    A_cl <- m$A - BK
    
    # 3. คำนวณ Kr (ใช้ solve() หา inverse)
    # Kr = -1 / (C %*% inv(A_cl) %*% B)
    # ผลลัพธ์ต้องเป็น Scalar (1x1)
    Kr_mat <- -1 / (m$C %*% solve(A_cl) %*% m$B)
    Kr <- as.numeric(Kr_mat) # แปลงเป็นตัวเลขธรรมดา
    
    # 4. สร้าง Closed-loop SS
    sys_cl <- ss(A_cl, m$B * Kr, m$C, m$D)
    res <- step(sys_cl, seq(0, 3, 0.01))
    
    output$sf_gains <- renderText({ sprintf("Gain K: [%.2f, %.2f]\nGain Kr: %.4f", K[1,1], K[1,2], Kr) })
    output$plot_sf <- renderPlot({
      ggplot(data.frame(t=as.numeric(res$t), y=as.numeric(res$y)), aes(t, y)) +
        geom_line(color="magenta", linewidth=1.5) + geom_hline(yintercept=1, linetype="dashed") +
        theme_minimal() + labs(title="State Feedback (Zero Error)")
    })
  })
}

shinyApp(ui, server)
