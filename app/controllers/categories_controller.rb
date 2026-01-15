class CategoriesController < ApplicationController
  before_action :require_login

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: "Category created"
    else
      render :new
    end
  end

  private
  def category_params
    params.require(:category).permit(:name)
  end
end
