# tests/testthat/test-scenarios.R
# Test realistic pilot study scenarios using helper functions

library(testthat)

test_that("all predefined scenarios work correctly", {
    # Test each predefined scenario
    for (scenario_name in names(test_scenarios)) {
        scenario <- test_scenarios[[scenario_name]]

        # Run complete scenario test
        result <- test_scenario(scenario)

        # Additional checks specific to each scenario
        expect_positive_integer(result$scenario$expected_enrolled)
        expect_positive_integer(result$scenario$expected_completed)
        expect_percentage_reasonable(result$me_enrollment)
        expect_percentage_reasonable(result$me_completion)

        # Print results for manual verification (only when running interactively)
        if (interactive()) {
            cat("\nScenario:", scenario_name)
            cat("\n  Approached:", scenario$n_approached)
            cat("\n  Expected enrolled:", scenario$expected_enrolled)
            cat("\n  Expected completed:", scenario$expected_completed)
            cat("\n  ME Enrollment: ±", round(result$me_enrollment, 1), "%")
            cat("\n  ME Completion: ±", round(result$me_completion, 1), "%")
        }
    }
})

test_that("margin of error decreases with larger sample sizes", {
    # Test that larger samples give more precision
    sample_sizes <- c(25, 50, 100, 200)
    me_values <- sapply(sample_sizes, function(n) {
        me(0.5, n) * 100
    })

    # Each subsequent ME should be smaller
    for (i in 2:length(me_values)) {
        expect_true(me_values[i] < me_values[i-1])
    }
})

test_that("extreme but valid scenarios work", {
    # Very pessimistic scenario
    pessimistic <- create_test_scenario("Pessimistic", 200, 25, 60, 40)
    result_pessimistic <- test_scenario(pessimistic)

    # Very optimistic scenario
    optimistic <- create_test_scenario("Very Optimistic", 40, 90, 98, 2)
    result_optimistic <- test_scenario(optimistic)

    # Both should produce valid results
    expect_true(is_reasonable_me(result_pessimistic$me_enrollment))
    expect_true(is_reasonable_me(result_optimistic$me_enrollment))
})

test_that("completion rate edge cases", {
    # High adherence, high attrition (contradictory but possible)
    high_both <- calculate_completion_rate(95, 30)  # 95% * (1-30%) = 66.5%
    expect_true(high_both > 0.6 && high_both < 0.7)

    # Low adherence, low attrition
    low_both <- calculate_completion_rate(60, 5)    # 60% * (1-5%) = 57%
    expect_true(low_both > 0.55 && low_both < 0.6)

    # Perfect scenario
    perfect <- calculate_completion_rate(100, 0)    # 100% * (1-0%) = 100%
    expect_equal(perfect, 1.0, tolerance = FLOAT_TOLERANCE)
})

test_that("grant text numerical accuracy", {
    # Test specific scenario and verify grant text would have correct numbers
    scenario <- create_test_scenario("Grant Test", 75, 55, 85, 12)

    # Calculate expected margins of error for grant text
    me_enroll_approached <- me(scenario$p_enroll / 100, scenario$n_approached) * 100
    me_complete <- me(scenario$completion_rate, scenario$expected_completed) * 100

    # These should match what would appear in grant text
    expect_true(is_reasonable_me(me_enroll_approached))
    expect_true(is_reasonable_me(me_complete))

    # Verify specific calculations
    expect_equal(scenario$expected_enrolled, 41)     # round(75 * 0.55)
    expect_equal(scenario$expected_completed, 31)    # round(41 * 0.748)
    expect_equal(round(scenario$completion_rate * 100, 1), 74.8)  # 85% * 88%
})

test_that("input boundary conditions", {
    # Test minimum valid inputs
    min_scenario <- create_test_scenario("Minimum", 1, 1, 1, 1)
    expect_equal(min_scenario$expected_enrolled, 0)   # round(1 * 0.01) = 0

    # Test maximum valid inputs
    max_scenario <- create_test_scenario("Maximum", 1000, 99, 99, 1)
    expect_equal(max_scenario$expected_enrolled, 990) # round(1000 * 0.99)

    # Test that we handle zero enrolled participants gracefully
    if (min_scenario$expected_enrolled == 0) {
        me_result <- me(0.01, 0)
        expect_true(is.na(me_result))  # Should return NA for n=0
    }
})

test_that("percentage rounding consistency", {
    # Test that our percentage display matches internal calculations
    test_values <- c(0.123, 0.456, 0.789, 0.999)

    for (val in test_values) {
        # Convert to percentage and back
        pct <- round(val * 100, 1)
        back_to_prop <- pct / 100

        # Should be very close (within rounding error)
        expect_equal(val, back_to_prop, tolerance = 0.01)
    }
})

test_that("realistic grant precision targets", {
    # Common grant scenarios - test that precision is reasonable for pilot studies

    # NIH R34 pilot study (small)
    r34_scenario <- create_test_scenario("R34 Pilot", 45, 60, 80, 15)
    r34_result <- test_scenario(r34_scenario)

    # Should have reasonable precision (typically want ME < 20% for pilots)
    expect_true(r34_result$me_enrollment < 25)
    expect_true(r34_result$me_completion < 25)

    # Foundation pilot grant (medium)
    foundation_scenario <- create_test_scenario("Foundation", 80, 50, 85, 10)
    foundation_result <- test_scenario(foundation_scenario)

    # Should have better precision with larger sample
    expect_true(foundation_result$me_enrollment < r34_result$me_enrollment)
    expect_true(foundation_result$me_completion < 20)
})
