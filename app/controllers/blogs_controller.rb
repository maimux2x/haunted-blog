# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_blog, only: %i[show edit update destroy]
  before_action :ensure_correct_user, only: %i[edit update destroy]
  before_action :ensure_owner, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    permit_params = %i[title content secret]
    permit_params.push(:random_eyecatch) if current_user.premium?
    params.require(:blog).permit(permit_params)
  end

  def ensure_correct_user
    raise ActiveRecord::RecordNotFound if @blog.user != current_user
  end

  def ensure_owner
    raise ActiveRecord::RecordNotFound if @blog.secret? && @blog.user != current_user
  end
end
