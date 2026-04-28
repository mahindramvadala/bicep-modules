using './module.bicep'

param nameSuffix = 'rt-mahi-dummy'

// Below are completely optional

/*

// Optional. Ony needed if route table needs to have custom routes within it.

param routes = [
  // Below example routes everything to Internet
  {
    name: 'default'
    addressPrefix: '0.0.0.0/0'
    nexHopType: 'Internet'
  }
]
*/

//param tags = {} //optional

//param disableBgpRoutePropagation = false //optional
