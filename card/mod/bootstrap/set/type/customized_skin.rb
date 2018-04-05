include_set Type::Scss

card_accessor :variables
card_accessor :bootswatch

# TODO: make it more visible/accessible/editable what's going on here in the content
# TODO: style: bootstrap cards load default bootstrap variables but
#       should depend on the theme specific variables
def content
  [
    Card["style: jquery-ui-smoothness"],
    Card["style: cards"],
    Card["style: right sidebar"],
    Card["font awesome"],
    Card["material icons"],
    Card[:bootstrap_functions],
    variables_card,
    Card[:bootstrap_variables],
    Card[:bootstrap_core],
    Card["style: bootstrap cards"],
    bootswatch_card
  ].map do |card|
    card.content
  end.join "\n"
end

def theme_card_name
  "#{@theme} skin"
end

event :validate_theme_template, :validate, on: :create do
  if (@theme = Env.params[:theme]).blank?
    errors.add :abort, "no theme given"
  elsif Card.fetch_type_id(theme_card_name) != Card::SkinID
    errors.add :abort, "not a valid theme: #{@theme}"
  elsif !Dir.exist?(source_dir)
    errors.add :abort, "can't find source for theme \"#{@theme}\""
  end
end

event :copy_theme, :prepare_to_store, on: :create do
  add_subfield_from_file :variables
  add_subfield_from_file :bootswatch
end

def source_dir
  @source_dir ||= ::File.expand_path "../../../vendor/bootswatch/dist/#{@theme}", __FILE__
end

def add_subfield_from_file subfield
  path = ::File.join source_dir, "_#{subfield}.scss"
  content = ::File.exist?(path) ? ::File.read(path) : ""

  add_subfield subfield, type_id: ScssID, content: content
end


format :html do
  def edit_fields
    [[:variables, {title: ""}],
     [:bootswatch, {title: "additional css changes"}]]
  end
end
