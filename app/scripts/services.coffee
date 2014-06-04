
DU_API = 'http://0.0.0.0:6543/'


vizBuilder = angular.module('vizBuilder')

# vizBuilder.config (RestangularProvider) ->


# console.log 'vizBuilder'
vizBuilder.factory 'datatableService', ($q, $timeout, $http, Restangular) ->
  Restangular.extendModel('datatables', (model) ->

    # Add ability to pull the field information into the datatable data
    model.fetchFields = () ->
      console.log 'fetchFields'
      console.log model
      if !model.structData
        structureDefURL = model['structure']
        console.log structureDefURL
        id = structureDefURL.substring structureDefURL.lastIndexOf('/') + 1
        console.log id
        structPromise = Restangular.one('qb-datastructdefs', id).get()
        structPromise.then (structData) ->
          console.log structData
          model.structure = structData

    return model
  )
  # datatableService = {}
  fetchTables: () ->
    # deferred = $q.defer()
    # $timeout( () ->
    #   $http.get(DU_API + 'datatablecatalogs/public').success((data) ->
    #     deferred.resolve(data)
    #   )
    # )
    # return deferred.promise

    promise = Restangular.all('datatablecatalogs/public').getList()

    return promise

  fetchTable: (tableRef) ->
    console.log 'fetchTable'

    # Restangular.extendModel('datatables', (model) ->
    #   model.fetchFields = () ->
    #     console.log 'fetchFields'
    #     # dtPromise = Restangular.one('datatables', 'dt1').get()
    #     # dtPromise.then (data) ->
    #     #   structureDefURL = data['qb:structure']['@id']
    #     #   console.log structureDefURL
    #     #   id = structureDefURL.substring structureDefURL.lastIndexOf('/') + 1
    #     #   console.log id
    #     #   structPromise = Restangular.one('qb-datastructdefs', id).get()
    #     #   structPromise.then (structData) ->
    #     #     console.log structData

    #   return model
    # )

    tableURL = tableRef['@id']
    id = tableURL.substring tableURL.lastIndexOf('/') + 1
    dtPromise = Restangular.one('datatables', id).get()
    dtPromise.then (datatable) ->
      console.log 'fetchFields promise'
      datatable.fetchFields()
    return dtPromise



renderers = [
  {
    rendererName: 'vizshare.barchart'
    thumbnail: '/images/chart_bar.png'
    datasets: [
      name: 'dataset1'
      fields: [
        {
          vizField: 'xAxis'
          dataType: ['string']
          required: true
        }
        {
          vizField: 'yAxis'
          dataType: ['decimal']
          required: true
        }
      ]
    ]
    vizOptions: {}
  }
  {
    rendererName: 'vizshare.piechart'
    thumbnail: '/images/chart_pie.png'
    datasets: [
      name: 'dataset1'
      fields: [
        {
          vizField: 'name'
          dataType: ['string']
          required: true
        }
        {
          vizField: 'value'
          dataType: ['decimal']
          required: true
        }
      ]
    ]
    vizOptions: {}
  }
  {
    rendererName: 'vizshare.geoleaflet'
    thumbnail: '/images/map.png'
    datasets: [
      name: 'dataset1'
      "fields": [
        {
            "vizField": "lat",
            "dataField": "Lat"
        },
        {
            "vizField": "long",
            "dataField": "Long"
        },
        {
            "vizField": "title",
            "dataField": "Name"
        },
        {
            "vizField": "value",
            "dataField": "Value"
        }
      ]
    ]
    vizOptions: {
        "scales": [
            {
                "name": "area",
                "type": "linear",
                "domain": {"data": "default", "vizField": "value"},
                "range": [50000, 100000]
            },
            {
                "name": "onetoten",
                "type": "linear",
                "domain": [1, 10],
                "range": [50000, 1000000]
            },
            {
                "name": "colours",
                "type": "linear",
                "domain": {"data": "default", "vizField": "value"},
                "range": ["red", "blue"]
            },
            {
                "name": "coloursonetoten",
                "type": "linear",
                "domain": [1, 10],
                "range": ["red", "blue"]
            }
        ],
        "marks": [
            {
                "type": "latlongcircle",
                "from": {"data": "default"},
                "properties": {
                    "enter": {
                        "lat": {"vizField": "lat"},
                        "long": {"vizField": "long"},
                        "size": {"scale": "onetoten", "vizField": "value"},
                        "text": {"vizField": "title"},
                        "fill": {"scale": "colours", "vizField": "value"}
                    }
                }
            }
        ]
    }
  }
]

vizBuilder.factory 'RendererService', () ->
  # datatableService = {}
  getRenderers: () ->
    return renderers
