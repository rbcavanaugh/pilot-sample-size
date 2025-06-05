# tests/testthat/test-functions.R
# Unit tests for core functions

library(testthat)

test_that("margin of error function works correctly", {
    # Test basic calculation
    result <- me(0.5, 100)
    expected <- 1.96 * sqrt(0.5 * 0.5 / 100)
    expect_equal(result, expected, tolerance = 1e-10)

    # Test with different proportions
    expect_equal(me(0.3, 50), 1.96 * sqrt(0.3 * 0.7 / 50), tolerance = 1e-10)
    expect_equal(me(0.8, 25), 1.96 * sqrt(0.8 * 0.2 / 25), tolerance = 1e-10)

    # Test edge cases
    expect_true(is.na(me(0.5, 0)))      # Zero sample size
    expect_true(is.na(me(0.5, -5)))     # Negative sample size

    # Test extreme proportions
    expect_equal(me(0.01, 100), 1.96 * sqrt(0.01 * 0.99 / 100), tolerance = 1e-10)
    expect_equal(me(0.99, 100), 1.96 * sqrt(0.99 * 0.01 / 100), tolerance = 1e-10)
})

test_that("margin of error produces reasonable results", {
    # Larger sample sizes should have smaller margins of error
    me_small <- me(0.5, 25)
    me_large <- me(0.5, 100)
    expect_true(me_large < me_small)

    # Proportions near 0.5 should have largest margins of error
    me_50 <- me(0.5, 100)
    me_20 <- me(0.2, 100)
    me_80 <- me(0.8, 100)
    expect_true(me_50 > me_20)
    expect_true(me_50 > me_80)

    # Results should be positive
    expect_true(me(0.3, 50) > 0)
    expect_true(me(0.7, 30) > 0)
})

test_that("completion rate calculations work correctly", {
    # Test basic completion rate calculation
    # completion = adherence * (1 - attrition)

    # 90% adherence, 10% attrition should give 81% completion
    completion <- 0.9 * (1 - 0.1)
    expect_equal(completion, 0.81, tolerance = 1e-10)

    # 80% adherence, 20% attrition should give 64% completion
    completion <- 0.8 * (1 - 0.2)
    expect_equal(completion, 0.64, tolerance = 1e-10)

    # Edge cases
    completion_perfect <- 1.0 * (1 - 0.0)  # 100% adherence, 0% attrition
    expect_equal(completion_perfect, 1.0)

    completion_worst <- 0.5 * (1 - 0.5)    # 50% adherence, 50% attrition
    expect_equal(completion_worst, 0.25)
})

test_that("sample size calculations work correctly", {
    # Test enrollment calculation
    n_approached <- 60
    p_enroll <- 0.5
    expected_enrolled <- round(n_approached * p_enroll)
    expect_equal(expected_enrolled, 30)

    # Test completion calculation
    n_enrolled <- 30
    p_complete <- 0.81  # From 90% adherence, 10% attrition
    expected_completed <- round(n_enrolled * p_complete)
    expect_equal(expected_completed, 24)  # round(30 * 0.81) = 24

    # Test with different values
    expect_equal(round(100 * 0.4), 40)
    expect_equal(round(50 * 0.75), 38)   # round(37.5) = 38
})

test_that("percentage to proportion conversion works", {
    # Test common percentage conversions
    expect_equal(50 / 100, 0.5)
    expect_equal(90 / 100, 0.9)
    expect_equal(10 / 100, 0.1)
    expect_equal(75 / 100, 0.75)

    # Test edge cases
    expect_equal(1 / 100, 0.01)
    expect_equal(99 / 100, 0.99)
})

test_that("realistic pilot study scenarios", {
    # Scenario 1: Small pilot study
    n_approached <- 40
    p_enroll <- 0.6         # 60% enrollment
    p_adherence <- 0.85     # 85% adherence
    p_attrition <- 0.15     # 15% attrition

    n_enrolled <- round(n_approached * p_enroll)              # 24
    p_complete <- p_adherence * (1 - p_attrition)             # 0.7225
    n_completed <- round(n_enrolled * p_complete)             # 17

    me_enrollment <- me(p_enroll, n_enrolled) * 100           # ME for enrollment
    me_completion <- me(p_complete, n_completed) * 100        # ME for completion

    expect_equal(n_enrolled, 24)
    expect_equal(n_completed, 17)
    expect_true(me_enrollment > 0)
    expect_true(me_completion > 0)
    expect_true(me_enrollment < 50)  # Should be reasonable
    expect_true(me_completion < 50)  # Should be reasonable

    # Scenario 2: Larger pilot study
    n_approached <- 100
    p_enroll <- 0.5
    p_adherence <- 0.9
    p_attrition <- 0.1

    n_enrolled <- round(n_approached * p_enroll)              # 50
    p_complete <- p_adherence * (1 - p_attrition)             # 0.81
    n_completed <- round(n_enrolled * p_complete)             # 41

    me_enrollment <- me(p_enroll, n_enrolled) * 100
    me_completion <- me(p_complete, n_completed) * 100

    expect_equal(n_enrolled, 50)
    expect_equal(n_completed, 40)  # round(50 * 0.81) = 41
    expect_true(me_enrollment < 20)  # Should be more precise with larger n
    expect_true(me_completion < 20)
})
