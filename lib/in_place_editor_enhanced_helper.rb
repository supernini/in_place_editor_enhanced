module InPlaceEditorEnhancedHelper
  # Makes an HTML element specified by the DOM ID +field_id+ become an in-place
  # editor of a property.
  #
  # A form is automatically created and displayed when the user clicks the element,
  # something like this:
  #   <form id="myElement-in-place-edit-form" target="specified url">
  #     <input name="value" text="The content of myElement"/>
  #     <input type="submit" value="ok"/>
  #     <a onclick="javascript to cancel the editing">cancel</a>
  #   </form>
  #
  # The form is serialized and sent to the server using an AJAX call, the action on
  # the server should process the value and return the updated value in the body of
  # the reponse. The element will automatically be updated with the changed value
  # (as returned from the server).
  #
  # Required +options+ are:
  # <tt>:url</tt>::       Specifies the url where the updated value should
  #                       be sent after the user presses "ok".
  #
  # Addtional +options+ are:
  # <tt>:rows</tt>::              Number of rows (more than 1 will use a TEXTAREA)
  # <tt>:cols</tt>::              Number of characters the text input should span (works for both INPUT and TEXTAREA)
  # <tt>:size</tt>::              Synonym for :cols when using a single line text input.
  # <tt>:cancel_text</tt>::       The text on the cancel link. (default: "cancel")
  # <tt>:save_text</tt>::         The text on the save link. (default: "ok")
  # <tt>:loading_text</tt>::      The text to display while the data is being loaded from the server (default: "Loading...")
  # <tt>:saving_text</tt>::       The text to display when submitting to the server (default: "Saving...")
  # <tt>:external_control</tt>::  The id of an external control used to enter edit mode.
  # <tt>:load_text_url</tt>::     URL where initial value of editor (content) is retrieved.
  # <tt>:options</tt>::           Pass through options to the AJAX call (see prototype's Ajax.Updater)
  # <tt>:with</tt>::              JavaScript snippet that should return what is to be sent
  #                               in the AJAX call, +form+ is an implicit parameter
  # <tt>:script</tt>::            Instructs the in-place editor to evaluate the remote JavaScript response (default: false)
  # <tt>:click_to_edit_text</tt>::The text shown during mouseover the editable text (default: "Click to edit")
  def in_place_editor_enhanced(field_id, options = {})
    function =  "new Ajax.InPlaceEditor("
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"

    js_options = {}
    js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
    js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
    js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
    js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
    js_options['rows'] = options[:rows] if options[:rows]
    js_options['cols'] = options[:cols] if options[:cols]
    js_options['size'] = options[:size] if options[:size]
    js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
    js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]
    js_options['ajaxOptions'] = options[:options] if options[:options]
    js_options['evalScripts'] = options[:script] if options[:script]
    js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
    js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
    function << ')'

    javascript_tag(function)
  end

  def in_place_collection_editor_enhanced(field_id, choices=[], options = {})
    function =  "new Ajax.InPlaceCollectionEditor("
    function << "'#{field_id}', "
    function << "'#{url_for(options[:url])}'"

    js_options = {}
    js_options['collection'] = choices.map {|choice| [ choice.last, choice.first ] }.to_json
    js_options['okButton'] = options[:ok_button] if options.has_key?(:ok_button)
    js_options['submitOnBlur'] = options[:submit_on_blur] if options.has_key?(:submit_on_blur)
    js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
    js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
    js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
    js_options['loadTextURL'] = "'#{url_for(options [:load_text_url])}'" if options[:load_text_url]
    js_options['savingText'] = %('#{options[:saving_text]}') if options[:saving_text]
    js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
    js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
    js_options['ajaxOptions'] = options[:options] if options[:options]
    js_options['evalScripts'] = options[:script] if options[:script]
    js_options['paramName'] = %('#{options[:param_name]}') if options[:param_name]
    js_options['highlightcolor'] = %('#{options[:highlightcolor]}') if options[:highlightcolor]
    js_options['highlightendcolor'] = %('#{options[:highlightendcolor]}') if options[:highlightendcolor]
    js_options['onFailure'] = %('#{options[:on_failure]}') if options[:on_failure]
    js_options['savingClassName'] = %('#{options[:saving_class_name]}') if options[:saving_class_name]
    js_options['clickToEditText'] = %('#{options[:click_to_edit_text]}') if options[:click_to_edit_text]
    js_options['cancelLink'] = options[:cancel_link] if options.has_key?(:cancel_link)
    function << (', ' + options_for_javascript(js_options)) unless js_options.empty?
    function << ')'

    javascript_tag(function)
    #new Ajax.InPlaceCollectionEditor(  'tobeedited2', '_ajax_inplaceeditor_result.html', {  collection: [[0,'one'],[1,'two'],[2,'three']],   ajaxOptions: {method: 'get'} //override so we can use a static for the result});
  end

  def in_place_collection_editor_enhanced_field(object, method, choices, tag_options = {}, in_place_selector_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    choices = object.send(method).class.find(:all).collect {|o|[o.name, o.id] } if choices == :all
    tag_options = { :tag => "span", :class => "in_place_select_field", :id => "#{object}_#{method}_#{tag.object.id}_in_place_selector"}.merge!(tag_options)
    in_place_selector_options[:url] ||= url_for({ :action => "set_#{object}_#{method}", :id => tag.object.id })
#    # in_place_selector_options = { :ok_button => false, :submit_on_blur => true }.merge!(in_place_selector_options)
    name = object.send(method).name rescue '(none)'
    content_tag(tag_options.delete(:tag), name, tag_options) +
      in_place_collection_editor_enhanced(tag_options[:id], choices, in_place_selector_options)
  end

  # Renders the value of the specified object and method with in-place editing capabilities.
  def in_place_editor_enhanced_field(object, method, tag_options = {}, in_place_editor_options = {})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = {:tag => "span", :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor", :class => "in_place_editor_field"}.merge!(tag_options)
    in_place_editor_options[:url] = in_place_editor_options[:url] || url_for({ :action => "set_#{object}_#{method}", :id => tag.object.id })
    name = tag.object.send(method) rescue '(none)'
    name = (name==''?'(none)':name)
    content_tag(tag_options.delete(:tag), name, tag_options) +
      in_place_editor_enhanced(tag_options[:id], in_place_editor_options)
  end
end
