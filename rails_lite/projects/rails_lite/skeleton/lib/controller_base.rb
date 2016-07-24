require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require_relative './session'


class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "double render error" if already_built_response?
    @res.status = 302
    @res['Location'] = url
    @already_built_response = true

    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "double render error" if already_built_response?
    @res.write(content)
    @res['Content-Type'] = content_type
    @already_built_response = true

    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_file_name = self.class.to_s.underscore #change to get rid of _controller
    current_directory = File.dirname(__FILE__)
    path = File.join(current_directory, '..', 'views', controller_file_name, "#{template_name}.html.erb")

    template = File.read(path)
    html_template = template_with_instance_variables(template)
    render_content(html_template, 'text/html')
  end

  def template_with_instance_variables(template) #make private
    ERB.new(template).result(binding)
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end
end
