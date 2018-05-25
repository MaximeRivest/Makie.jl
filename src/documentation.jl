# TODO: figure out where to put the below
# General function signatures and usage
# `func` are the function names, e.g. `lines`, `scatter`, `surface`, etc.
#
# # creates a new plot + scene object
# `func(args...; kw_args...)`
#
# # creates a new plot as a subscene of a scene object
# `func(scene::SceneLike, args...; kw_args...)`
#
# # adds a plot in-place to the current_scene()
# `func!(args...; kw_args...)`
#
# # adds a plot in-place to the current_scene() as a subscene
# `func!(scene::SceneLike, args...; kw_args...)`
#
# # `[]` means an optional argument. `Attributes` is a Dictionary of attributes:
# `func[!]([scene], kw_args::Attributes, args...)`


"""
    to_func(Typ)

Maps the input of a Type name to its cooresponding function.
"""
function to_func(Typ::Type{T}) where T <: AbstractPlot
    #TODO: this is not working yet, but will become deprecated in the new branch
    sym = Typ.name.mt.name
    string(sym) |> lowercase |> Symbol
    f = getfield(current_module(), sym)
end

# hard-coding for the case of scatter
function to_func(Typ::Type{T}) where T <: AbstractPlot
    sym = Symbol("scatter")
    f = getfield(current_module(), sym)
end

to_func(func::Function) = func

"""
    to_type(func)

Maps the input of a function name to its cooresponding Type.
"""
function to_type(func::Function)
    sym = typeof(func).name.mt.name
    Typ = getfield(Makie,Symbol(titlecase(string(sym))))
end



help(func; kw_args...) = help(STDOUT, func; kw_args...)

"""
    help(func)

Welcome to Makie.

For help on a specific function's arguments, type `help_arguments(function_name)`.
For help on a specific function's attributes, type `help_attributes(function_name)`.
"""
function _help(io::IO, input::Type{T}; extended = false) where T <: AbstractPlot
    func = to_func(input)

    # Print docstrings
    println(Base.Docs.doc(input))

    # Arguments
    help_arguments(io, func)
    println(io, "Please refer to @ref[convert_arguments] to find the full list of accepted arguments\n")

    # Keyword arguments
    help_attributes(io, input; extended = extended)

    println(io, "You can use $(input) in the following way:\n@query_database [$(input)]")

end

function _help(io::IO, input::Function; extended = false)
    _help(io, to_type(input); extended = extended)
end


function help(io::IO, input::Type{T}; extended = false) where T <: AbstractPlot
    buffer = IOBuffer()
    _help(buffer, input; extended = extended)
    Base.Markdown.parse(String(take!(buffer)))
end

function help(io::IO, input::Function; extended = false)
    buffer = IOBuffer()
    _help(buffer, to_type(input); extended = extended)
    Base.Markdown.parse(String(take!(buffer)))
end

"""
    help_signatures(func)

Returns a list of signatures for function `func`.
"""
function help_arguments(io, x::Function)
#TODO: this is currently hard-coded
    println(io, "`$x` has the following function signatures: \n")
    println(io, "```")
    println(io, "  ", "(Vector, Vector)")
    println(io, "  ", "(Vector, Vector, Vector)")
    println(io, "  ", "(Matrix)")
    println(io, "```")
end



"""
    help_attributes(Typ)

Returns a list of attributes for the plot type `Typ`.
The attributes returned extend those attribues found in the `default_theme`.

Use the optional keyword argument `extended` (default = `false`) to show
in addition the default values of each attribute.
"""
function help_attributes(io, Typ::Type{T}; extended = false) where T <: Makie.AbstractPlot # TODO: Not sure if this is a good way to generalize for any function
    # get and sort list of attributes from function (using Scatter as an example)
    # this is a symbolic dictionary, with symbols as the keys
    attributes = sort(Makie.default_theme(nothing, Typ))

    # get list of default attributes to filter out
    # and show only the attributes that are not default attributes
    filter_keys = collect(keys(Makie.default_theme(nothing)))

    # count the character length of the longest key
    longest = 0
    for k in keys(attributes)
        currentlength = length(string(k))
        if currentlength > longest
            longest = currentlength
        end
    end
    extra_padding = 2

    # increase verbosity if extended kwarg is on
    if extended
        println(io, "Available attributes and their defaults for `$Typ` are: \n")
        println(io, "```")
        for (attribute, value) in attributes
            if !(attribute in filter_keys)
                padding = longest - length(string(attribute)) + extra_padding
                println(io, "  ", attribute, " "^padding, Makie.value(value))
            end
        end
        println(io, "```")
    else
        println(io, "Available attributes for `$Typ` are: \n")
        println(io, "```")
        for (attribute, value) in attributes
            if !(attribute in filter_keys)
                println(io, "  ", attribute)
            end
        end
        println(io, "```")
    end
end