class CartController < ApplicationController
  before_action :added_product, only: [:update]
  before_action :sign_customer_up, only: [:create]
  before_action :authenticate_customer
  before_action :cart_product, only: [:destroy, :update_quantity]

  def show
    session[:cart] ||= []
    @order = Order.new
    @cart = []
    @total_price = 0
    session[:cart].each do |item|
      product = Product.find(item['product'])
      @total_price += (product.price * item['amount'].to_i)
      @cart.push({ product: product, amount: item['amount'] })
      @order.products << product
    end
  end

  def create
    order_params = params.require(:order).permit(cart: [])
  end

  def edit_quantity
    session[:cart].each { |item| item['amount'] += 1 if item['product'] == params[:id].to_i and item['amount'] < Product.find(item['product'].to_i).stock_quantity } if params[:method] == 'add'
    session[:cart].each { |item| item['amount'] -= 1 if item['product'] == params[:id].to_i and item['amount'] > 1 } if params[:method] == 'sub'
    session[:cart_expire_time] = Time.now.to_i + 86400
    redirect_to cart_path
  end
  def checkout
    # quantity = params.require(:quantity).permit(:id)
    redirect_to new_customer_registration_path and return unless user_signed_in?
    order = current_user.orders.create!
    total_price = 0
    session[:cart].each do |item|
      product = Product.find(item['product'])
      total_price += (product.price * item['amount'].to_i)
      # product.update!(order_id)
      OrderProductRecord.create!(price: product.price, quantity: item['amount'].to_i, order_id: order.id, product_id: product.id)
    end
        order.update!(total_price: total_price, purchase_date:Time.now)
    session[:cart] = []

    redirect_to products_path(page: 1)
  end

  def update
    ensure_cart_session_exists
    prod = Product.find(@_product['product_id'].to_i)
    amount = @_product['amount'].to_i
    session[:cart] = [] unless session[:cart]
    if session[:cart].any? { |item| item['product'] == prod.id }
      session[:cart].each { |item| item['amount'] += amount if item['product'] == prod.id }
    else
      session[:cart] << { product: prod.id, amount: amount }
    end
    session[:cart_expire_time] = Time.now.to_i + 86400
    reserve_item(prod.id, amount.to_i)
    # redirect_to :back
  end

  def destroy
    p @product_id
    ensure_cart_session_exists
    prod = Product.find(@product_id)
    session[:cart] = session[:cart].delete_if do |item|
      if item['product'].to_i == @product_id.to_i
        undo_item_reserve_transaction(prod.id, item['amount'].to_i)
        session[:cart_expire_time] = Time.now.to_i + 86400
        true
      end
    end
    redirect_to cart_path
  end

  def destroy_all
    session[:cart].delete_if do |item|
      undo_item_reserve_transaction(item['product'].to_i, item['amount'])
      true
    end
    session[:cart_expire_time] = Time.now.to_i
  end

  def ensure_cart_session_exists
    session[:cart] ||= []
    session[:cart_expire_time] ||= Time.now.to_i
    session.delete :cart if Time.now.to_i >= session[:cart_expire_time]
  end

  private

  def reserve_item(id, amount)
    Product.find(id).decrement!('stock_quantity', amount)
  end

  def undo_item_reserve_transaction(id, amount)
    Product.find(id).increment!('stock_quantity', amount)
  end

  def added_product
    @_product = params.require(:product).permit(:product_id, :amount)
  end

  def sign_customer_up
    redirect_to new_customer_registration_path unless customer_signed_in?
  end

  def authenticate_customer
    redirect_to root_path unless customer_signed_in? or !user_signed_in?
  end

  def cart_product
    @product_id = params.require(:id)
  end
end
