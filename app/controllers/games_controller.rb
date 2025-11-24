require 'open-uri'

class GamesController < ApplicationController
  def new
    session[:letters] = generate_grid(10)
    session[:score] = 0 unless session[:game_in_progress]
    @letters = session[:letters]

    session[:game_in_progress] = nil
  end

  def score
    @word = params[:word]
    token = params[:authenticity_token]
    @grid = session[:letters]
    @score = 0
    @bg = "danger"
    @params = params
    grid_check = word_in_grid(@word, @grid.dup)
    dict_check = dictionary_check(@word)

    if grid_check && dict_check && valid_authenticity_token?(session, token)
      @score = return_scrabble_score(@word)
      @message = "Well done!"
      @bg = "success"
    elsif !valid_authenticity_token?(session, token)
      @message = "Wrong authenticity token"
    elsif !grid_check
      @message = "Your word is not in the grid!"
    elsif !dict_check
      @message = "Your word is not in the dictionary!"
    else
      @message = "Something went wrong, couldn't score your word"
    end
    session[:letters] = []
    session[:score] += @score
    @grand_score = session[:score]
    session[:game_in_progress] = true
  end

  def validate
    word = params[:word]
    grid = session[:letters]

    is_valid_grid = word_in_grid(word, grid.dup)
    is_valid_dict = dictionary_check(word)

    render json: {
      grid: is_valid_grid,
      dictionary: is_valid_dict
    }
  end

  private

  SCRABBLE_SCORE = { "A" => 1, "B" => 3, "C" => 3, "D" => 2, "E" => 1, "F" => 4, "G" => 2, "H" => 4, "I" => 1, "J" => 8,
                    "K" => 5, "L" => 1, "M" => 3, "N" => 1, "O" => 1, "P" => 3, "Q" => 10, "R" => 1, "S" => 1, "T" => 1,
                    "U" => 1, "V" => 4, "W" => 4, "X" => 8, "Y" => 4, "Z" => 10 }

  def generate_grid(grid_size)
    grid = [['A', 'E', 'I', 'O', 'U'].sample]
    grid << ('A'..'Z').to_a.sample until grid.size == grid_size
    grid
  end

  def return_scrabble_score(word)
    word.chars.sum do |letter|
      SCRABBLE_SCORE[letter.upcase]
    end
  end

  def dictionary_check(word)
    url = "https://dictionary.lewagon.com/#{word.downcase}"
    word_check_serialized = URI.open(url).read
    JSON.parse(word_check_serialized)['found']
  end

  def word_in_grid(word, grid)
    word.chars.all? do |letter|
      if grid.include?(letter.upcase)
        grid.delete_at(grid.index(letter.upcase))
        true
      else
        false
      end
    end
  end
end
