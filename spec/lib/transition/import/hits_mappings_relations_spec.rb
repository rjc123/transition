require 'spec_helper'
require 'transition/import/hits_mappings_relations'

describe Transition::Import::HitsMappingsRelations do
  describe '.refresh!', testing_before_all: true do
    before :all do
      @host = create :host
      @site = @host.site

      @hit_with_mapping      = create :hit, path: '/this/exists', host: @host
      @c14n_hit_with_mapping = create :hit, path: '/this/Exists?and=can&canonicalize=1', host: @host
      @hit_without_mapping   = create :hit, path: '/this/does/not/exist', host: @host

      @mapping               = create :mapping, path: '/this/exists', site: @site

      Transition::Import::HitsMappingsRelations.refresh!
    end

    it 'points the hit for which there is a path at the corresponding mapping' do
      @hit_with_mapping.reload.mapping.should == @mapping
    end

    it 'points the c14nable hit for which there is a path at the corresponding mapping' do
      @c14n_hit_with_mapping.reload.mapping.should == @mapping
    end

    it 'leaves the hit for which there is no mapping alone' do
      @hit_without_mapping.reload.mapping.should be_nil
    end

    it 'has a SitePath per uncanonicalized hit (all of them!)' do
      SitePath.all.should have(3).site_paths
    end
  end
end
