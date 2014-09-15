require "spec_helper"
require 'go_import'

describe "File" do
    let ("file") {
        GoImport::File.new
    }

    it "is valid when it has path, created_by and organization" do
        # given
        file.path = "offert.docx"
        file.created_by = GoImport::CoworkerReference.new( { :integration_id => "123" } )
        file.organization = GoImport::OrganizationReference.new( { :integration_id => "456" } )

        # when, then
        file.validate.should eq ""
    end

    it "is valid when it has name, path, created_by and deal" do
        # given
        file.name = "Offert"
        file.path = "offert.docx"
        file.created_by = GoImport::CoworkerReference.new( { :integration_id => "123" } )
        file.deal = GoImport::DealReference.new( { :integration_id => "456" } )

        # when, then
        file.validate.should eq ""
    end

    it "is not valid when it has path and deal" do
        # must have a created_by
        # given
        file.path = "c:\mydocs\deal.xls"
        file.deal = GoImport::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        file.validate.length.should be > 0
    end

    it "is not valid when it has path and created_by" do
        # must have an deal or organization
        # given
        file.path = "c:\mydocs\deal.xls"
        file.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )

        # when, then
        file.validate.length.should be > 0
    end

    it "is not valid when it has deal and created_by" do
        # must have a path
        # given
        file.created_by = GoImport::CoworkerReference.new( { :integration_id => "123", :heading => "billy bob" } )
        file.deal = GoImport::DealReference.new({ :integration_id => "456", :heading => "The new deal" })

        # when, then
        file.validate.length.should be > 0
    end

    it "will use filename from path as name if name set not explicit" do
        # given
        file.path = "some/files/myfile.docx"
        file.name = ""

        # when, then
        file.name.should eq 'myfile.docx'
    end

    it "will use name as name if name is set explicit" do
        # given
        file.path = "some/files/myfile.docx"
        file.name = "This is a filename"

        # when, then
        file.name.should eq 'This is a filename'
    end

    it "will not have a name if name is not set or path is empty" do
        # given
        file.path = ""
        file.name = ""

        # when, then
        file.name.should eq ''
    end

    it "will auto convert org to org.ref during assignment" do
        # given
        org = GoImport::Organization.new({:integration_id => "123", :name => "Beagle Boys!"})

        # when
        file.organization = org

        # then
        file.organization.is_a?(GoImport::OrganizationReference).should eq true
    end

    it "will auto convert deal to deal.ref during assignment" do
        # given
        deal = GoImport::Deal.new({:integration_id => "123" })
        deal.name = "The new deal"

        # when
        file.deal = deal

        # then
        file.deal.is_a?(GoImport::DealReference).should eq true
    end

    it "will auto convert coworker to coworker.ref during assignment" do
        # given
        coworker = GoImport::Coworker.new({:integration_id => "123" })
        coworker.parse_name_to_firstname_lastname_se "Billy Bob"

        # when
        file.created_by = coworker

        # then
        file.created_by.is_a?(GoImport::CoworkerReference).should eq true
    end


end
