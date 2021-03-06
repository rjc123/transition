#encoding: utf-8
require 'spec_helper'

describe VersionsHelper do
  describe '#friendly_field_name' do
    specify { helper.friendly_field_name('http_status').should == 'Type' }
    specify { helper.friendly_field_name('archive_url').should == 'Alternative Archive URL' }
    specify { helper.friendly_field_name('miscellaneous').should == 'Miscellaneous' }
  end

  describe '#friendly_changeset_title' do
    specify { helper.friendly_changeset_title({'id' => 1}).should == 'Mapping created' }
    specify { helper.friendly_changeset_title({'archive_url' => 1}).should == 'Alternative Archive URL updated' }
    specify { helper.friendly_changeset_title({'miscellaneous' => 1}).should == 'Miscellaneous updated' }
    specify { helper.friendly_changeset_title({'archive_url' => 1, 'miscellaneous' => 1}).should == 'Multiple properties updated' }
    specify { helper.friendly_changeset_title({'http_status' => ['301', '410']}).should == 'Switched mapping to an Archive' }
    specify { helper.friendly_changeset_title({'http_status' => ['410', '301']}).should == 'Switched mapping to a Redirect' }
  end

  describe '#friendly_changeset_old_to_new' do
    specify { helper.friendly_changeset_old_to_new('misc', ['old', 'new']).should == 'old → new' }
    specify { helper.friendly_changeset_old_to_new('misc', ['', 'new']).should == '<blank> → new' }
    specify { helper.friendly_changeset_old_to_new('http_status', ['410', '301']).should == 'Archive → Redirect' }
    specify { helper.friendly_changeset_old_to_new('http_status', ['', '301']).should == '<blank> → Redirect' }
  end
end
