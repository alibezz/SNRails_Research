class ResearchesController < ApplicationController
  resource_controller

  actions :all, :except => [:new, :edit, :create, :update, :destroy]
end
