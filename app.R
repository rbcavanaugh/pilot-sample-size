# Pilot Study Sample Size Precision Calculator
# Single file Shiny app (app.R)

library(shiny)

# Margin of error function
me <- function(p, n) {
    if (n <= 0) return(NA)
    1.96 * sqrt(p * (1 - p) / n)
}

# UI
ui <- fluidPage(
    titlePanel("Pilot Study Sample Size Precision Calculator"),

    sidebarLayout(
        sidebarPanel(width = 4,
                     tabsetPanel(id = "tabs",
                                 tabPanel("Study Design",
                                          br(),
                                          h5("Calculate from study parameters"),
                                          p("Enter your study design - the app will calculate expected sample sizes and margins of error. The app
                                            uses information about the total number of participants you think you might try to recruit (approach), how many
                                            you expect to enroll, their adherence in treatment, and attrition rates to estimate the expected sample sizes
                                            for your study. You can skip any of these steps by setting values to 100% (0% for attrition)"),

                                          numericInput("n_approached",
                                                       "Expected participants approached:",
                                                       value = 60,
                                                       min = 1,
                                                       step = 1),

                                          numericInput("p_enroll",
                                                       "Expected enrollment rate (%):",
                                                       value = 50,
                                                       min = 1,
                                                       max = 99,
                                                       step = 5),

                                          numericInput("p_adherence",
                                                       "Expected adherence rate (% of enrolled):",
                                                       value = 90,
                                                       min = 1,
                                                       max = 99,
                                                       step = 5),

                                          numericInput("p_attrition",
                                                       "Expected attrition rate (% of enrolled):",
                                                       value = 10,
                                                       min = 1,
                                                       max = 99,
                                                       step = 5)
                                 ),

                                 tabPanel("Direct Calculator",
                                          br(),
                                          h5("Calculate margin of error directly"),
                                          p("Enter a specific sample size and rate - get the margin of error immediately."),

                                          numericInput("n_direct",
                                                       "Sample size (n):",
                                                       value = 25,
                                                       min = 1,
                                                       step = 1),

                                          numericInput("p_direct",
                                                       "Rate (%):",
                                                       value = 50,
                                                       min = 1,
                                                       max = 99,
                                                       step = 5),

                                          helpText("Example: 'I have 25 people, what's the margin of error for a 50% success rate?'")
                                 )
                     ),

                     hr(),

                     helpText("Confidence intervals calculated using 95% level (z = 1.96)"),
                     helpText("Margin of error = 1.96 × √(p × (1-p) / n)"),
                     helpText("Completion rate = adherence × (1 - attrition)")
        ),

        mainPanel(width = 8,
                  tabsetPanel(
                      tabPanel("Results",
                               h4("Results"),

                               # Study Design Results
                               conditionalPanel(
                                   condition = "input.tabs == 'Study Design'",
                                   fluidRow(
                                       column(6,
                                              wellPanel(
                                                  h5("Expected Sample Sizes"),
                                                  textOutput("expected_enrolled"),
                                                  textOutput("expected_completed")
                                              )
                                       ),
                                       column(6,
                                              wellPanel(
                                                  h5("Margins of Error (±%)"),
                                                  textOutput("me_enrollment"),
                                                  textOutput("me_completion"),
                                                  textOutput("me_approached")
                                              )
                                       )
                                   ),

                                   hr(),
                                   h5("Interpretation"),
                                   htmlOutput("interpretation")
                               ),

                               # Direct Calculator Results
                               conditionalPanel(
                                   condition = "input.tabs == 'Direct Calculator'",
                                   fluidRow(
                                       column(12,
                                              wellPanel(
                                                  h5("Margin of Error Result"),
                                                  textOutput("me_direct_result")
                                              )
                                       )
                                   ),

                                   hr(),
                                   h5("Interpretation"),
                                   htmlOutput("interpretation_direct")
                               )
                      ),

                      tabPanel("Grant Text",
                               conditionalPanel(
                                   condition = "input.tabs == 'Study Design'",
                                   h4("Sample Grant Language"),

                                   wellPanel(
                                       style = "background-color: #f8f9fa;",
                                       h5("Instructions:"),
                                       p("The text below uses your study design parameters. Bold placeholders need to be customized:"),
                                       tags$ul(
                                           tags$li(tags$b("[INTERVENTION]"), " - Replace with your intervention name"),
                                           tags$li(tags$b("[MEASURE]"), " - Replace with your specific measures"),
                                           tags$li(tags$b("[COMPLETION_CRITERIA]"), " - Replace with your completion criteria"),
                                           tags$li(tags$b("[ENROLLMENT_THRESHOLD]"), " - Set your enrollment feasibility threshold"),
                                           tags$li(tags$b("[COMPLETION_THRESHOLD]"), " - Set your completion feasibility threshold"),
                                           tags$li(tags$b("[ASSESSMENT_THRESHOLD]"), " - Set your assessment feasibility threshold")
                                       )
                                   ),

                                   wellPanel(
                                       htmlOutput("grant_text"),
                                       br(),
                                       actionButton("copy_text", "Copy to Clipboard", class = "btn-primary")
                                   )
                               ),

                               conditionalPanel(
                                   condition = "input.tabs == 'Direct Calculator'",
                                   h4("Grant Text"),
                                   p("Grant text is only available for the Study Design tab. Please switch to the Study Design tab to generate grant language.")
                               )
                      )
                  )
        )
    )
)

# Server
server <- function(input, output) {

    # Calculate completion rate from adherence and attrition (Study Design tab)
    p_complete <- reactive({
        (input$p_adherence / 100) * (1 - input$p_attrition / 100)
    })

    # Calculated sample sizes (Study Design tab)
    n_enrolled <- reactive({
        round(input$n_approached * (input$p_enroll / 100))
    })

    n_completed <- reactive({
        round(n_enrolled() * p_complete())
    })

    # Expected sample sizes
    output$expected_enrolled <- renderText({
        paste("Expected enrolled:", n_enrolled(), "participants")
    })

    output$expected_completed <- renderText({
        paste("Expected completed:", n_completed(), "participants",
              paste0("(", round(p_complete() * 100, 1), "% completion rate)"))
    })

    # Margin of error calculations (Study Design tab)
    output$me_enrollment <- renderText({
        me_val <- me(input$p_enroll / 100, n_enrolled()) * 100
        if (is.na(me_val)) {
            "Enrollment ME: Invalid sample size"
        } else {
            paste("Enrollment rate ME: ±", round(me_val, 1), "%")
        }
    })

    output$me_completion <- renderText({
        me_val <- me(p_complete(), n_completed()) * 100
        if (is.na(me_val)) {
            "Completion ME: Invalid sample size"
        } else {
            paste("Completion rate ME: ±", round(me_val, 1), "%")
        }
    })

    output$me_approached <- renderText({
        me_val <- me(input$p_enroll / 100, input$n_approached) * 100
        if (is.na(me_val)) {
            "Approached ME: Invalid sample size"
        } else {
            paste("Enrollment (total approached) ME: ±", round(me_val, 1), "%")
        }
    })

    # Interpretation (Study Design tab)
    output$interpretation <- renderUI({
        me_enroll <- me(input$p_enroll / 100, n_enrolled()) * 100
        me_complete <- me(p_complete(), n_completed()) * 100

        HTML(paste0(
            "<strong>What this means:</strong><br>",
            "• With ", n_enrolled(), " enrolled participants, your enrollment rate estimate will be within ±",
            round(me_enroll, 1), "% of the true rate 95% of the time<br>",
            "• With ", n_completed(), " completed participants, your completion rate estimate will be within ±",
            round(me_complete, 1), "% of the true rate 95% of the time<br>",
            "• Completion rate = adherence × (1 - attrition) = ", round(p_complete() * 100, 1), "%<br><br>",
            "<em>Smaller margins of error indicate more precise estimates for your pilot study.</em>"
        ))
    })

    # Direct Calculator - Simple margin of error calculation
    output$me_direct_result <- renderText({
        me_val <- me(input$p_direct / 100, input$n_direct) * 100
        if (is.na(me_val)) {
            "Invalid inputs"
        } else {
            paste("Margin of Error: ±", round(me_val, 1), "%")
        }
    })

    output$interpretation_direct <- renderUI({
        me_val <- me(input$p_direct / 100, input$n_direct) * 100

        HTML(paste0(
            "<strong>What this means:</strong><br>",
            "With ", input$n_direct, " participants and an expected rate of ", input$p_direct,
            "%, your estimate will be within ±", round(me_val, 1),
            "% of the true rate 95% of the time.<br><br>",
            "<em>This is a direct margin of error calculation using the formula: 1.96 × √(p × (1-p) / n)</em>"
        ))
    })

    # Grant Text Generator
    output$grant_text <- renderUI({
        me_enroll <- me(input$p_enroll / 100, input$n_approached) * 100
        me_complete <- me(p_complete(), n_completed()) * 100

        grant_text <- paste0(
            "<h5>Sample Size Justification:</h5>",
            "<p>Consistent with the intent of a feasibility study, this exploratory analysis is primarily intended to develop the intervention and <strong>is not powered to conduct significance testing</strong>. Based upon our previous studies in developing and testing behavioral interventions, we expect that a minimum of ", n_completed(), " participants completing the intervention will give us rich data to determine the utility of the intervention. Therefore, we will approach up to ", input$n_approached, " participants.</p>",

            "<p>With ", input$n_approached, " participants approached, we will have reasonable statistical precision in estimating the primary feasibility targets of ", input$p_enroll, "% enrollment rate (95% CI margin within ±", round(me_enroll, 1), "%) and ", round(p_complete() * 100, 1), "% completion rates (within ±", round(me_complete, 1), "%).</p>",

            "<h5>Feasibility Endpoints:</h5>",
            "<p>We will calculate sample proportions with 95% confidence intervals for the feasibility endpoints alongside certain pre-specified thresholds, as follows:</p>",
            "<ul>",
            "<li><em>Eligibility rate</em> (Number of patients screening positive & eligible / Number screened)</li>",
            "<li><em>Enrollment rate</em> (Number of participants enrolled / Number screening positive & eligible)</li>",
            "<li><em>Intervention completion rate</em> (Number of <strong>[INTERVENTION]</strong> participants who complete <strong>[COMPLETION_CRITERIA]</strong> / Number enrolled in <strong>[INTERVENTION]</strong> condition)</li>",
            "<li><em>Assessment completion rate</em> (Number participants completing <strong>[MEASURE]</strong> / Number of participants enrolled)</li>",
            "</ul>",

            "<h5>Thresholds for determining feasibility:</h5>",
            "<p>The enrollment rate is an important marker of feasibility as it reflects how many patients experiencing the targeted problem choose to enroll in the study. Enrollment rate of at least <strong>[ENROLLMENT_THRESHOLD]</strong>% will indicate feasibility.</p>",

            "<p>The intervention completion rate is influenced by the level of burden of the intervention, the health status of the participants, and the perceived benefit of the intervention. We will consider it feasible if at least <strong>[COMPLETION_THRESHOLD]</strong>% of participants complete <strong>[COMPLETION_CRITERIA]</strong> of the <strong>[INTERVENTION]</strong> sessions.</p>",

            "<p>The assessment completion rate is influenced by the burden (time and cognition) involved, the perceived meaningfulness of items, and the flexibility of mode of completion. For this study, an assessment completion rate of at least <strong>[ASSESSMENT_THRESHOLD]</strong>% will indicate feasibility.</p>"
        )

        HTML(grant_text)
    })

    # Copy button (basic implementation)
    observeEvent(input$copy_text, {
        showNotification("Grant text is ready to copy! Select the text above and copy manually.",
                         type = "message", duration = 3)
    })
}

# Run the app
shinyApp(ui = ui, server = server)
