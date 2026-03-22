# MN5552: Robotics and Manufacturing Automation

[![R Application](https://img.shields.io/badge/R-Shiny-blue?logo=r)](https://shiny.posit.co/)
[![Status](https://img.shields.io/badge/Status-Deployed-brightgreen)](https://xikr3m-bi2f.shinyapps.io/MN5552-Motor-Control/)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2025b-orange?logo=mathworks)](https://www.mathworks.com/)

---

<div align="center">

<img src="brunel.png" height="100" alt="Brunel University London Logo"/>

## MN5552: Robotics and Manufacturing Automation
### Brunel University London
### Department of Mechanical and Aerospace Engineering

</div>

---

## Project Overview

**Design and Simulation of a DC Motor Speed Control System** This project demonstrates modern control theory by developing an interactive web application using **R Shiny**. The tool is designed to analyze DC motor behavior and implement **PID** and **State Feedback Control** strategies to achieve high-performance industrial standards.

---

## Assignment Objectives

The project is divided into four key analytical phases (P1 - P4):

1. **System Modeling (P1):** Developing mathematical models using **State-Space Representation** and **Transfer Functions**.
2. **Open-loop Analysis (P2):** Testing the motor's natural response to evaluate stability and speed characteristics without a controller.
3. **PID Controller Tuning (P3):** Designing and tuning $K_p, K_i, and K_d$ gains to compare the performance of P, PI, and PID control setups.
4. **State Feedback Design (P4):** Using **Pole Placement** techniques and calculating **Feedforward Gain ($K_r$)** to achieve a "Zero Steady-State Error" response.

---

## MATLAB & Simulink Integration

While the final app is web-based, the core engineering logic was verified using **MATLAB/Simulink**:
* **P1 & P2:** `p1_and_p2_state_space.slx` and `p1_and_p2_transfer.slx` for baseline analysis.
* **P3 (PID):** `p3_transfer_p_pi_pid.slx` for comparing different controller types.
* **P4 (State Feedback):** `p4_state_space.slx` for simulating advanced closed-loop systems.
* **MATLAB App:** `PID_App.mlapp` provided for local testing within the MATLAB environment.

---

## Interactive Web Application (R Shiny)

To make this control tool accessible to other engineers, the system has been deployed as a web application.

🚀 **Live Demo:** [DC Motor Control Suite](https://xikr3m-bi2f.shinyapps.io/MN5552-Motor-Control/)

### **How to Run Locally:**
1. Install required packages in R: `install.packages(c("shiny", "control", "ggplot2", "shinydashboard"))`
2. Open the file `app.R`.
3. Click the **"Run App"** button in RStudio.

---

## Project Advisor

<div align="center">
<img src="Dr_Xinli_Du.jpg" height="160" alt="Dr. Xinli Du"/>
<br/>
<b>Dr. Xinli Du</b>  
Senior Lecturer in Mechanical Engineering
</div>

---

## File Structure

```bash
├── app.R                       # R Shiny Web Application
├── PID_App.mlapp               # Standalone MATLAB App Designer file
├── script_p1_to_p4.m           # Pre-calculation Script
├── p1_and_p2_state_space.slx   # Simulink: Open-loop SS model
├── p1_and_p2_transfer.slx      # Simulink: Open-loop TF model
├── p3_transfer_p_pi_pid.slx    # Simulink: PID Comparison model
├── p4_state_space.slx          # Simulink: State Feedback model
├── brunel.png                  # University Logo
├── DC motor.jpg                # Motor Reference Image
├── Dr_Xinli_Du.jpg             # Advisor Image
└── README.md                   # Project Documentation (This file)
```
