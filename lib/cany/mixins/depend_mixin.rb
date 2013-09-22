module Cany::Mixins::DependMixin
  # @overload depend(dep)
  #   @param depend[Cany::Dependency] A complete Dependency object
  # @overload depend(default, opts)
  #   Creates a new dependency object
  #   @param depend[Symbol] The default
  #   @param opts[Hash] Options influencing the create Dependency object.
  #   @option opts[Symbol, Array<Symbol>] :situation For which situations
  #     is this dependency. Default is :runtime
  #   @option opts[Symbol] :version The default version
  def create_dep(depend, opts={})
    if depend.kind_of? Cany::Dependency
      depend
    else
      opts = { situation: :runtime, version: nil }.merge opts
      dep = Cany::Dependency.new
      dep.define_default depend, opts[:version]
      dep.situations = opts[:situation]
      dep
    end
  end
end
