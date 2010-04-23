module InPlaceEditorEnhanced
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_enhanced_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        if !@item.update_attributes({attribute => params[:value]})
          @item = object.to_s.camelize.constantize.find(params[:id])
        end

        if params[:editorId].include?("in_place_selector")
          name_to_print = @item.send(attribute).to_s
          object.to_s.camelize.constantize.reflect_on_all_associations(:belongs_to).each do |item|
            if item.association_foreign_key==attribute.to_s
              name_to_print = item.name.to_s.camelize.constantize.in_place_enhanced_selector_value(@item[:category_id])
            end
          end
          render :text => name_to_print
        else
          render :text => @item.send(attribute).to_s
        end        
      end
    end
  end
end
