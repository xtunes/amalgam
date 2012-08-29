require 'spec_helper'

describe Page do
  before do
    setup_tree Page, <<-ENDTREE
        - home
        - page1:
            - page2
        - page4
      ENDTREE
  end

  it 'fails validation when slug is not unique under one parent' do
    # ::Page.create(:slug => 'home',:title => 'home').should have(1).error_on(:slug)
    nodes(:page1).children.create(:slug => 'page2', :title => 'page2').should have(1).error_on(:slug)
  end
end
