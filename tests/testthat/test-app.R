# # tests/testthat/test-app.R
# # Integration tests for Shiny app behavior
#
# library(testthat)
# library(shinytest2)
#
# test_that("app launches successfully", {
#     skip_if_not_installed("shinytest2")
#
#     app <- AppDriver$new("../../app.R", name = "pilot-calculator")
#
#     # Check that the app loaded
#     expect_true(app$wait_for_idle())
#
#     # Check that key UI elements exist
#     expect_true(app$get_value(input = "n_approached") == 60)  # Default value
#     expect_true(app$get_value(input = "p_enroll") == 50)      # Default value
#
#     app$stop()
# })
#
# test_that("Study Design tab calculations work correctly", {
#     skip_if_not_installed("shinytest2")
#
#     app <- AppDriver$new("../../app.R", name = "pilot-calculator")
#     app$wait_for_idle()
#
#     # Set specific values
#     app$set_inputs(
#         n_approached = 60,
#         p_enroll = 50,
#         p_adherence = 90,
#         p_attrition = 10
#     )
#     app$wait_for_idle()
#
#     # Check calculated values
#     expected_enrolled <- 30  # 60 * 0.5
#     expected_completed <- 24 # 30 * (0.9 * (1 - 0.1)) = 30 * 0.81 = 24.3 ≈ 24
#
#     # Get the output text and extract numbers
#     enrolled_text <- app$get_value(output = "expected_enrolled")
#     completed_text <- app$get_value(output = "expected_completed")
#
#     expect_true(grepl("30", enrolled_text))   # Should contain "30 participants"
#     expect_true(grepl("24", completed_text))  # Should contain "24 participants"
#
#     app$stop()
# })
#
# test_that("Direct Calculator tab works correctly", {
#     skip_if_not_installed("shinytest2")
#
#     app <- AppDriver$new("../../app.R", name = "pilot-calculator")
#     app$wait_for_idle()
#
#     # Switch to Direct Calculator tab
#     app$set_inputs(tabs = "Direct Calculator")
#     app$wait_for_idle()
#
#     # Set values for direct calculation
#     app$set_inputs(
#         n_direct = 25,
#         p_direct = 50
#     )
#     app$wait_for_idle()
#
#     # Check margin of error result
#     me_result <- app$get_value(output = "me_direct_result")
#     expect_true(grepl("±", me_result))        # Should contain ± symbol
#     expect_true(grepl("%", me_result))        # Should contain % symbol
#     expect_true(grepl("19.6", me_result))     # Expected ME for n=25, p=0.5
#
#     app$stop()
# })
#
# test_that("input validation works", {
#     skip_if_not_installed("shinytest2")
#
#     app <- AppDriver$new("../../app.R", name = "pilot-calculator")
#     app$wait_for_idle()
#
#     # Test extreme values
#     app$set_inputs(
#         n_approached = 1,      # Very small sample
#         p_enroll = 1,          # Minimum percentage
#         p_adherence = 99,      # Maximum percentage
#         p_attrition = 1        # Minimum percentage
#     )
#     app$wait_for_idle()
#
#     # Should still produce valid outputs (no errors)
#     enrolled_text <- app$get_value(output = "expected_enrolled")
#     expect_true(grepl("participants", enrolled_text))
#
#     # Test larger values
#     app$set_inputs(
#         n_approached = 1000,   # Large sample
#         p_enroll = 99,         # High enrollment
#         p_adherence = 95,      # High adherence
#         p_attrition = 5        # Low attrition
#     )
#     app$wait_for_idle()
#
#     # Should still work
#     enrolled_text <- app$get_value(output = "expected_enrolled")
#     expect_true(grepl("participants", enrolled_text))
#
#     app$stop()
# })
#
# test_that("tab switching works correctly", {
#     skip_if_not_installed("shinytest2")
#
#     app <- AppDriver$new("../../app.R", name = "pilot-calculator")
#     app$wait_for_idle()
#
#     # Start on Study Design tab
#     expect_equal(app$get_value(input = "tabs"), "Study Design")
#
#     # Switch to Direct Calculator
#     app$set_inputs(tabs = "Direct Calculator")
#     app$wait_for_idle()
#     expect_equal(app$get_value(input = "tabs"), "Direct Calculator")
#
#     # Switch back to Study Design
#     app$set_inputs(tabs = "Study Design")
#     app$wait_for_idle()
#     expect_equal(app$get_value(input = "tabs"), "Study Design")
#
#     app$stop()
# })
#
# test_that("grant text generates correctly", {
#     skip_if_not_installed("shinytest2")
#
#     app <- AppDriver$new("../../app.R", name = "pilot-calculator")
#     app$wait_for_idle()
#
#     # Make sure we're on Study Design tab
#     app$set_inputs(tabs = "Study Design")
#     app$wait_for_idle()
#
#     # Set known values
#     app$set_inputs(
#         n_approached = 50,
#         p_enroll = 60,
#         p_adherence = 80,
#         p_attrition = 20
#     )
#     app$wait_for_idle()
#
#     # Check that grant text contains expected elements
#     grant_text <- app$get_value(output = "grant_text")
#
#     expect_true(grepl("50 participants", grant_text))          # Sample size
#     expect_true(grepl("60%", grant_text))                      # Enrollment rate
#     expect_true(grepl("feasibility study", grant_text))        # Key phrase
#     expect_true(grepl("\\[INTERVENTION\\]", grant_text))       # Placeholder present
#     expect_true(grepl("statistical precision", grant_text))    # Key concept
#
#     app$stop()
# })
#
# test_that("reactive updates work correctly", {
#     skip_if_not_installed("shinytest2")
#
#     app <- AppDriver$new("../../app.R", name = "pilot-calculator")
#     app$wait_for_idle()
#
#     # Set initial values
#     app$set_inputs(n_approached = 40, p_enroll = 50)
#     app$wait_for_idle()
#
#     # Get initial result
#     initial_enrolled <- app$get_value(output = "expected_enrolled")
#
#     # Change enrollment rate
#     app$set_inputs(p_enroll = 75)
#     app$wait_for_idle()
#
#     # Get updated result
#     updated_enrolled <- app$get_value(output = "expected_enrolled")
#
#     # Results should be different
#     expect_false(identical(initial_enrolled, updated_enrolled))
#     expect_true(grepl("30", updated_enrolled))  # 40 * 0.75 = 30
#
#     app$stop()
# })
