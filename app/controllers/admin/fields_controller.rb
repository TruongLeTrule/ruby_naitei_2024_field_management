class Admin::FieldsController < Admin::AdminController
  load_resource except: %i(create)

  def index
    @q = @fields.ransack params[:q]
    @pagy, @fields = pagy @q.result.includes(:field_type, :order_relationships)
  end

  def new; end

  def create
    @field = Field.new field_params
    @field.image.attach params.dig(:field, :image)

    if @field.save
      flash[:success] = t ".success"
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if params.dig(:field, :image).present?
      @field.image.attach(params.dig(:field, :image))
    end

    if @field.update field_params
      flash.now[:success] =
        t ".success", deep_intepolation: true, field: @field.name
      render :edit, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @field.has_any_uncompleted_order?
      flash.now[:danger] = t ".has_uncompleted_order"
      return render :edit, status: :see_other
    end

    @field.destroy
    flash[:success] = t ".success", deep_intepolation: true, field: @field.name
    redirect_to root_path, status: :see_other
  end

  private

  def field_params
    params.require(:field).permit Field::CREATE_ATTRIBUTES
  end
end
