class SearchAdapter
  GEO_PARAMS = [:address, :distance]
  MUST_PARAMS = [:position_ids, :project_type_ids, :customer_name_ids, :certification_ids, :clearance_level_ids, :clearance_active]
  SHOULD_PARAMS = []
  KEYWORD_PARAMS = [:q]
  PARAM_ID_LOCATION = { position_ids: 'project_histories.project_history_positions.position.id',
                        clearance_level_ids: 'military.clearance_level_id',
                        clearance_active: 'military.clearance_active',
                        project_type_ids: 'project_histories.project_type.id',
                        customer_name_ids: 'project_histories.customer_name.id',
                        certification_ids: 'certifications.id' }

  def initialize(params)
    fail ArgumentError unless params.is_a?(Search)
    @query = {}
    @params = params
  end

  def to_query
    build_bool
    build_geo
    build_q

    @query
  end

  private

  def initalize_filter_query
    @query[:filter] = { and: [] } unless @query.key?(:filter) && @query[:filter].key?(:and)
  end

  def build_bool
    must_params = build MUST_PARAMS
    should_params = build SHOULD_PARAMS

    bool = {}
    bool[:must] = build_terms(must_params) unless must_params.empty?
    bool[:should] = build_terms(should_params) unless should_params.empty?

    unless bool.empty?
      initalize_filter_query
      @query[:filter][:and] << { bool: bool }
    end

    @query
  end

  def build_q
    keyword_params = build KEYWORD_PARAMS
    return nil unless @params.q


    @query[:query] = {multi_match: {
      fields: search_fields,
      query: keyword_params[:q],
    }.merge(term_type_option)}

    @query
  end

  def term_type_option
    case @params.term_type
    when 'all_words'
      {operator: "and"}
    when 'exact'
      {type: "phrase"}
    when 'any_words'
      {operator: "or"}
    end
  end

  def search_fields
    %w(skills_list abstract full_name address military.branch resume_attachment
      project_histories.description
      project_histories.project_type.label
      project_histories.project_history_positions.position.label)
  end

  def build_geo
    return nil unless @params.address && @params.distance

    initalize_filter_query
    geo = { geo_distance: { address: {} } }
    geo[:geo_distance][:address] = { lat: @params.lat, lon: @params.lon }
    geo[:geo_distance][:distance] = "#{@params.distance}mi"

    @query[:filter][:and] << geo
    @query
  end

  def build_sort
    [{ updated_at: { order: :desc } },
     '_score'
    ]
  end

  def build_terms(terms)
    obj = {}
    obj.compare_by_identity
    results = []

    return nil if terms.empty?

    terms.to_a.each do |ele, result|
      results << {terms: { get_name_from_key(ele) => result }}
    end
    results
  end

  def get_name_from_key(key)
    PARAM_ID_LOCATION[key]
  end

  def build(list)
    list.each_with_object({}) do |k, obj|
      if @params.respond_to?(k) && !@params.send(k).blank?
        obj[k] = @params.send(k)
      end
      obj
    end
  end
end
