module HomeHelper

  def get_colour_class(toggle_value)
    cls = toggle_value == true ? 'warning' : 'success'
    "bg-#{cls}"
  end
end
