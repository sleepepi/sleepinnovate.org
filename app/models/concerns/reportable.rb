# frozen_string_literal: true

# Computes scores for MyApnea core summary report.
module Reportable
  extend ActiveSupport::Concern

  def report_promis_disturbance(data)
    return if data.nil?
    array = []
    array << data.dig("data", "baseline", "quality_sleep_quality")
    array << data.dig("data", "baseline", "quality_refreshing")
    array << data.dig("data", "baseline", "quality_problem")
    array << data.dig("data", "baseline", "quality_difficulty")
    array << data.dig("data", "baseline", "quality_restless")
    array << data.dig("data", "baseline", "quality_tried_hard")
    array << data.dig("data", "baseline", "quality_worried")
    array << data.dig("data", "baseline", "quality_satisfied")
    return if array.count(&:blank?).positive?
    raw_score = array.sum(&:to_i)
    promis_disturbance_tscore(raw_score)
  end

  def report_promis_impairment(data)
    return if data.nil?
    array = []
    array << data.dig("data", "baseline", "quality_sleepy")
    array << data.dig("data", "baseline", "quality_alert_woke")
    array << data.dig("data", "baseline", "quality_tired")
    array << data.dig("data", "baseline", "quality_problems")
    array << data.dig("data", "baseline", "quality_concentrating")
    array << data.dig("data", "baseline", "quality_irritable")
    array << data.dig("data", "baseline", "quality_sleepy_daytime")
    array << data.dig("data", "baseline", "quality_staying_awake")
    return if array.count(&:blank?).positive?
    raw_score = array.sum(&:to_i)
    promis_impairment_tscore(raw_score)
  end

  def report_meq(data)
    return if data.nil?
    score = data.dig("data", "baseline", "daynight_feeling_best")
    return if score.nil?
    score.to_i * 10
  end

  def report_wpai_overall_work_impairment(data)
    return if data.nil?
    work_sick_missed_work = data.dig("data", "baseline", "work_sick_missed_work") # Q2
    work_working_hours = data.dig("data", "baseline", "work_working_hours") # Q4
    work_productivity = data.dig("data", "baseline", "work_productivity") # Q5
    return if work_sick_missed_work.nil? || work_working_hours.nil? || work_productivity.nil?

    work_missed = work_sick_missed_work.to_f / (work_sick_missed_work.to_f + work_working_hours.to_f) # Q2/(Q2+Q4)
    impairment_while_working = work_productivity.to_f / 10 # Q5 / 10

    # Q2/(Q2+Q4) + [(1-(Q2/(Q2+Q4))) * (Q5/10)]
    percent_overall_work_impairment = (work_missed + ((1 - work_missed) * impairment_while_working)) * 100
    percent_overall_work_impairment
  end

  def report_wpai_overall_activity_impairment(data)
    return if data.nil?

    work_leisure = data.dig("data", "baseline", "work_leisure") # Q6
    return if work_leisure.nil?

    impairment_while_activity = (work_leisure.to_f / 10) * 100 # Q6 / 10
  end

  def report_well_being_pcornet(data)
    return if data.nil?
    pcors = []
    pcors << data.dig("data", "baseline", "general_depressed")
    pcors << data.dig("data", "baseline", "general_fatigued")
    pcors << data.dig("data", "baseline", "general_mental_health")
    pcors << data.dig("data", "baseline", "general_uneasy")
    return if pcors.count(&:blank?).positive?
    pcors.sum(&:to_i) / 4
  end

  def report_bmi(data)
    return if data.nil?
    height = data.dig("data", "baseline", "demo_height")
    weight = data.dig("data", "baseline", "demo_weight")
    return unless weight.is_a?(Numeric) && height.is_a?(Numeric) && height.positive?
    weight * 703.0 / (height * height)
  end

  def promis_disturbance_tscore(raw_score)
    table = [
      [8, 28.9],
      [9, 33.1],
      [10, 35.9],
      [11, 38],
      [12, 39.8],
      [13, 41.4],
      [14, 42.9],
      [15, 44.2],
      [16, 45.5],
      [17, 46.7],
      [18, 47.9],
      [19, 49],
      [20, 50.1],
      [21, 51.2],
      [22, 52.2],
      [23, 53.3],
      [24, 54.3],
      [25, 55.3],
      [26, 56.3],
      [27, 57.3],
      [28, 58.3],
      [29, 59.4],
      [30, 60.4],
      [31, 61.5],
      [32, 62.6],
      [33, 63.7],
      [34, 64.8],
      [35, 66.1],
      [36, 67.5],
      [37, 69],
      [38, 70.8],
      [39, 73],
      [40, 76.5]
    ]
    table.find { |score, _| score == raw_score }&.last
  end

  def promis_impairment_tscore(raw_score)
    table = [
      [8, 30],
      [9, 35.2],
      [10, 38.7],
      [11, 41.4],
      [12, 43.6],
      [13, 45.5],
      [14, 47.3],
      [15, 48.9],
      [16, 50.3],
      [17, 51.6],
      [18, 52.9],
      [19, 54],
      [20, 55.1],
      [21, 56.1],
      [22, 57.2],
      [23, 58.2],
      [24, 59.3],
      [25, 60.3],
      [26, 61.3],
      [27, 62.3],
      [28, 63.3],
      [29, 64.3],
      [30, 65.3],
      [31, 66.3],
      [32, 67.3],
      [33, 68.4],
      [34, 69.5],
      [35, 70.7],
      [36, 71.9],
      [37, 73.4],
      [38, 75],
      [39, 76.9],
      [40, 80.1]
    ]
    table.find { |score, _| score == raw_score }&.last
  end
end
