# tests/testthat/helper.R
# Helper functions for testing

# Helper function to calculate expected completion rate
calculate_completion_rate <- function(adherence_pct, attrition_pct) {
    (adherence_pct / 100) * (1 - attrition_pct / 100)
}

# Helper function to calculate expected enrolled participants
calculate_enrolled <- function(n_approached, enroll_pct) {
    round(n_approached * (enroll_pct / 100))
}

# Helper function to calculate expected completed participants
calculate_completed <- function(n_enrolled, adherence_pct, attrition_pct) {
    completion_rate <- calculate_completion_rate(adherence_pct, attrition_pct)
    round(n_enrolled * completion_rate)
}

# Helper function to test if margin of error is reasonable
is_reasonable_me <- function(me_value, max_expected = 50) {
    !is.na(me_value) && me_value > 0 && me_value < max_expected
}

# Helper to create test scenarios
create_test_scenario <- function(name, n_approached, p_enroll, p_adherence, p_attrition) {
    list(
        name = name,
        n_approached = n_approached,
        p_enroll = p_enroll,
        p_adherence = p_adherence,
        p_attrition = p_attrition,
        expected_enrolled = calculate_enrolled(n_approached, p_enroll),
        expected_completed = calculate_completed(
            calculate_enrolled(n_approached, p_enroll),
            p_adherence,
            p_attrition
        ),
        completion_rate = calculate_completion_rate(p_adherence, p_attrition)
    )
}

# Common test scenarios
test_scenarios <- list(
    small_pilot = create_test_scenario("Small Pilot", 30, 50, 80, 20),
    medium_pilot = create_test_scenario("Medium Pilot", 60, 60, 90, 10),
    large_pilot = create_test_scenario("Large Pilot", 100, 70, 85, 15),
    conservative = create_test_scenario("Conservative", 80, 40, 75, 25),
    optimistic = create_test_scenario("Optimistic", 50, 80, 95, 5)
)

# Function to test a complete scenario
test_scenario <- function(scenario) {
    # Test basic calculations
    testthat::expect_equal(
        calculate_enrolled(scenario$n_approached, scenario$p_enroll),
        scenario$expected_enrolled
    )

    testthat::expect_equal(
        calculate_completed(scenario$expected_enrolled, scenario$p_adherence, scenario$p_attrition),
        scenario$expected_completed
    )

    # Test margin of error calculations
    me_enroll <- me(scenario$p_enroll / 100, scenario$expected_enrolled) * 100
    me_complete <- me(scenario$completion_rate, scenario$expected_completed) * 100

    testthat::expect_true(is_reasonable_me(me_enroll))
    testthat::expect_true(is_reasonable_me(me_complete))

    return(list(
        scenario = scenario,
        me_enrollment = me_enroll,
        me_completion = me_complete
    ))
}

# Tolerance for floating point comparisons
FLOAT_TOLERANCE <- 1e-10

# Common assertions
expect_percentage_reasonable <- function(value, min_val = 0, max_val = 100) {
    testthat::expect_true(value >= min_val)
    testthat::expect_true(value <= max_val)
}

expect_positive_integer <- function(value) {
    testthat::expect_true(is.numeric(value))
    testthat::expect_true(value >= 0)
    testthat::expect_equal(value, as.integer(value))
}
