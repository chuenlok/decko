# shared methods for card collections (Pointers, Searches, Sets, etc.)
module ClassMethods
  def search spec, comment=nil
    results = ::Card::Query.run(spec, comment)
    if block_given? && results.is_a?(Array)
      results.each { |result| yield result }
    end
    results
  end

  def count_by_wql spec
    spec = spec.clone
    spec.delete(:offset)
    search spec.merge(return: "count")
  end

  def find_each options={}
    # this is a copy from rails (3.2.16) and is needed because this
    # is performed by a relation (ActiveRecord::Relation)
    find_in_batches(options) do |records|
      records.each { |record| yield record }
    end
  end

  def find_in_batches options={}
    if block_given?
      super(options) do |records|
        yield(records)
        Card::Cache.reset_soft
      end
    else
      super(options)
    end
  end
end

def collection?
  item_cards != [self]
end

def context_card
  @context_card || self
end

def with_context card
  old_context = @context_card
  @context_card = card if card
  yield
ensure
  @context_card = old_context
end

def contextual_content context_card, format_args={}, view_args={}
  view = view_args.delete(:view) || :core
  with_context context_card do
    format(format_args).render! view, view_args
  end
end

format :html do
  view :count do |args|
    card.item_names(args).size
  end

  view :carousel do
    bs_carousel unique_id, 0 do
      nest_item_array.each do |rendered_item|
        item(rendered_item)
      end
    end
  end
end
