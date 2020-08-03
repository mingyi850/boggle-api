require_relative '../services/games_creator.rb'

class GamesController < ApplicationController
  def index
    games = Game.order('created_at DESC');
    render json: {data: games }, status: :ok
  end

  def show
    game = Game.find(params[:id])
    GamesManager.update_time_left!(game)
    render json: { data: game.as_json(only: %i[id token duration board time_left points]) }, status: :ok
  end

  def create
    game = GamesCreator.create_game(game_params, params)
    if game.save
      render json: {message:'Created Game', data: game.as_json(only: %i[id token duration board])}, status: :ok
    else
      render json: {message: 'Error', data: game.errors}, status: :unprocessable_entity
    end
  rescue GamesCreator::GameCreationError => e
    if e.instance_of?(GamesCreator::InvalidBoardError)
      render json: {message: 'Error: Invalid Board Passed', data: params}, status: :unprocessable_entity
    end
  end

  private

  def game_params
    params.require(:duration)
    { duration: params[:duration] }
  end

 end
