class PeopleController < ApplicationController
  # GET /people
  # GET /people.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => Person.all }
      
      # With the Flexigrid, we need to render Json data
      format.js do
        # What is the first line of the result set we want ? (due to pagination. 0 = first)
        offset = (params["page"].to_i-1)*params["rp"].to_i if params["page"] and params["rp"]

        # Conditions passed by flexigrid
        conditions = [params["qtype"]+"=?", params["query"]] if params["query"] and params["query"].strip!=""
        people = Person.where(conditions)

        # Total count of lines, before paginating
        total = people.count

        # People from the page
        people_de_la_page = people
          .order([params["sortname"], params["sortorder"]].join(" "))
          .offset(offset)
          .limit(params["rp"]).all
        
        # Juste an ugly trick to add a bouton (button) method to the class, to use it in the Flexigrid
        Person.class_eval do 
          def bouton
            %{<img src="images/close.png">}
          end
        end

        # Rendering
        render :json => {
            :rows=>people_de_la_page.collect{|r| {:id=>r.id, :cell=>[r.name, r.firstname, r.date_of_birth, r.bouton]}}, 
            :page=>params["page"],
            :total=>total
          }.to_json
          
      end #format.js
      
    end #respond_to
    
  end #index method

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        format.html { redirect_to(@person, :notice => 'Person was successfully created.') }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end
end
