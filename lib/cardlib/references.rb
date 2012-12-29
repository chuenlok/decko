module Cardlib::References
  include Card::ReferenceTypes

  def name_referencers link_name=nil
    link_name = link_name.nil? ? key : link_name.to_name.key
    
    Card.all :joins => :out_references, :conditions => { :card_references => { :referenced_name => link_name } }
  end

  def extended_referencers
    # FIXME .. we really just need a number here.
    (dependents + [self]).map(&:referencers).flatten.uniq
  end

  # ---------- Referenced cards --------------

  def referencers
    return [] unless refs = references
    refs.map(&:card_id).map( &Card.method(:fetch) )
  end

  def includers
    return [] unless refs = inclusions
    refs.map(&:card_id).map( &Card.method(:fetch) )
  end

=begin
  def existing_referencers
    return [] unless refs = references
    refs.map(&:referenced_name).map( &Card.method(:fetch) ).compact
  end

  def existing_includers
    return [] unless refs = inclusions
    refs.map(&:referenced_name).map( &Card.method(:fetch) ).compact
  end
=end

  # ---------- Referencing cards --------------

  def referencees
    return [] unless refs = out_references
    refs. map { |ref| Card.fetch ref.referenced_name, :new=>{} }
  end

  def includees
    return [] unless refs = out_inclusions
    refs.map { |ref| Card.fetch ref.referenced_name, :new=>{} }
  end

  protected

  def update_references_on_create
    Card::Reference.update_on_create self

    # FIXME: bogus blank default content is set on hard_templated cards...
    Account.as_bot do
      Wagn::Renderer.new(self, :not_current=>true).update_references
    end
    expire_templatee_references
  end

  def update_references_on_update
    Wagn::Renderer.new(self, :not_current=>true).update_references
    expire_templatee_references
  end

  def update_references_on_destroy
    Card::Reference.update_on_destroy(self)
    expire_templatee_references
  end



  def self.included(base)

    super

    base.class_eval do

      # ---------- Reference associations -----------
      has_many :references,  :class_name => :Reference, :foreign_key => :referenced_card_id
      has_many :inclusions, :class_name => :Reference, :foreign_key => :referenced_card_id,
        :conditions => { :link_type => INCLUDE }

      has_many :out_references,  :class_name => :Reference, :foreign_key => :card_id
      has_many :out_inclusions, :class_name => :Reference, :foreign_key => :card_id, :conditions => { :link_type => INCLUDE }

      after_create  :update_references_on_create
      after_destroy :update_references_on_destroy
      after_update  :update_references_on_update
    end
  end
end
