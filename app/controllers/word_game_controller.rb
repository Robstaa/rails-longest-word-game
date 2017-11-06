require 'open-uri'
require 'json'

class WordGameController < ApplicationController
  def game
    @grid = generate_grid.join
    @time_start = Time.now
  end

  def score
    # raise
    @run_game = run_game(params[:word], params[:grid], params[:time_start], Time.now)
  end

  def generate_grid
    letters = ("a".."z").to_a
    grid = []
    20.times { grid << letters.sample.upcase }
    grid
  end

  def checking(attempt, grid, link, result)
    attempt_array = attempt.upcase.split("")
    if attempt_array.uniq.all? { |letter| attempt_array.count(letter) <= grid.count(letter) } && link["found"]
      result[:score] = (6**attempt.length * 0.45**result[:time] * 10).round(2)
      result[:message] = "Well done! '#{attempt}'' got you #{result[:score]} points."
    elsif attempt_array & grid.chars == attempt_array
      result[:message] = "The word '#{attempt}' is not an english word."
    else
      result[:message] = "'#{attempt}' is not in the grid."
    end
    result
  end

  def run_game(attempt, grid, start_time, end_time)
    link = JSON.parse(open("https://wagon-dictionary.herokuapp.com/#{attempt}").read)
    result = { time: end_time - Time.parse(start_time), score: 0 }
    checking(attempt, grid, link, result)
  end
end
