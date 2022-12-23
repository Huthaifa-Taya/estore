class ProductsController < ApplicationController
  before_action :authenticate_admin_or_owner!, only: [:new, :edit, :update, :destroy]
  before_action :authenticate_customer, only: [:filter]
  before_action :product_params, only: [:create, :update]
  before_action :product_id, only: [:edit, :show, :update, :destroy]
  before_action :filter_params, only: [:filter]
  before_action :categories, only: [:new, :index]
  before_action :filters, only: [:index, :index_med_price, :index_high_price, :index_low_price]
  helper_method :customer_signed_in?

  def index

    if owner_signed_in?
      @products = current_user.latest_products.page params[:page]
      elsif admin_signed_in?
      @products = Product.order(created_at: :desc).page params[:page]
    elsif params[:scope].nil?
      @products = Product.order(created_at: :desc).page params[:page]
    else
      case params[:scope]
      when 'low_price'
         # @products = (session[:low_price_products].map { |id| Product.find(id) }).order(created_at: :desc).page params[:page] if session[:low_price_products]
         @products = Product.price_less_than(150).order(created_at: :desc).page params[:page]
      when 'high_price'
        @products = Product.price_more_than(500).order(created_at: :desc).page params[:page]
      when 'med_price'
        @products = Product.price_in_between({lower_val: 150, upper_val: 500}).order(created_at: :desc).page params[:page]
      when 'search'
        @products = Product.where("name like ?", "%#{params[:keyword]}%").order(created_at: :desc).page params[:page]
      end
      end
  end


  def filter
    case @_filters['name']
    when 'category'
      redirect_to categories_path
    when 'low_price'
      redirect_to products_path(scope: :low_price)
    when 'medium_price'
      redirect_to products_path(scope: :med_price)
    when 'high_price'
      redirect_to products_path(scope: :high_price)
    when 'all_products'
      redirect_to products_path
    else
      if @_filters['search']
        redirect_to products_path(scope: :search, keyword: @_filters['search'])
      else
      redirect_to products_path
      end
    end
    # redirect_to :action => :index, filter: @_filters['name']
  end

  def new
    @product = Product.new
    @stores = if admin_signed_in?
                Store.order(created_at: :desc)
              else
                current_user.stores
              end
  end

  def create
    product = current_user.products.create!(@_params.slice(:name, :price, :store_id, :stock_quantity, :image))
    product.categories << @_params[:categories].drop(1).map { |cat_id| Category.find(cat_id) }
    redirect_to product_path(product)
  end

  def show
    @product = Product.find(@id)
  end

  def edit
    @product = Product.find(@id)
    @categories = Category.all
    @stores = Store.order(created_at: :desc)
  end

  def update
    id = @_params.delete(:id).to_i
    category_ids = @_params.delete(:categories)
    category_ids.shift
    product = Product.find(id)
    category_ids.delete_if { |cat_id| product.categories.include?(cat_id.to_i) }
    product.update!(@_params)
    product.categories << category_ids.map { |cat_id| Category.find(cat_id.to_i)}
    redirect_to product_path(id: id) and return
  end

  def destroy
    Product.delete(params[:product_id].to_i)
    redirect_to products_path
  end

  def destroy_store_products
    store_id = params[:store_id]
    Store.find(store_id).products.each { |product| product.delete }
  end

  private

  def product_id
    @id = params[:id]
  end

  def product_params
    @_params = params.require(:product).permit(:id, :name, :price, :stock_quantity, :store_id, :image, categories: [])
  end

  def authenticate_admin_or_owner!
    redirect_to products_path unless admin_signed_in? or owner_signed_in?
  end

  def authenticate_customer
    redirect_to products_path unless customer_signed_in? or !user_signed_in?
  end

  def filter_params
    @_filters = params.require(:filters).permit(:name, :search)
  end

  def categories
    @categories = Category.order(created_at: :desc)
  end

  def filters
    @filters = Filter.all
  end

end
