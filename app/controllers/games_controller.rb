require_relative '../services/games_creator.rb'

# Controller class for requests to games
class GamesController < ApplicationController

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { message: 'Invalid body received' }, status: :bad_request
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { message: 'record not found' }, status: :not_found
  end

  def show
    game = Game.find(params[:id])
    game.update_time_left
    render json: game.as_json(only: %i[id token duration board time_left points]),
           status: :ok
  end

  def create
    game = GamesCreator.create_game(game_params)
    if game.save
      render json: game.as_json(only: %i[id token duration board]), status: :created
    else
      render json: {message: 'Error', data: game.errors}, status: :unprocessable_entity
    end
  rescue GamesCreator::GameCreationError => e
    if e.instance_of?(GamesCreator::InvalidBoardError)
      render json: {message: 'Error: Invalid Board Passed', data: params}, status: :bad_request
    end
  end

  def update
    game = Game.find(play_params[:id])

    GamesManager.validate_game_token(game, play_params[:token])
    GamesManager.check_game_expired(game)
    GamesManager.verify_word(play_params[:word], game)

    game.update_game_state!(play_params[:word])
    render json: game.as_json(success_params), status: :ok

  rescue GamesManager::GameError => e
    handle_game_error(e)
  end

   private

  # strong params for create requests
  def game_params
    params.require(%i[duration random])
    params.permit(%i[duration random board])
  end

  # strong params for put requests
  def play_params
    params.require(%i[word token id])
    params.permit(%i[word token id])
  end
  
  def success_params
    { only: %i[id token duration board time_left points] }
  end

  # Error handler for all game errors
  def handle_game_error(error)
    if error.instance_of?(GamesManager::InvalidTokenError)
      render json: { message: 'Invalid Token', data: params }, status: :unauthorized
    elsif error.instance_of?(GamesManager::GameExpiredError)
      render json: { message: 'Game has expired' }, status: :not_found
    else
      render json: { message: 'Invalid Word' }, status: :bad_request
    end
  end

 end
