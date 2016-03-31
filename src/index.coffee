Promise = require 'bluebird'
needle = Promise.promisifyAll(require 'needle')
cloudscraper = require 'cloudscraper'

module.exports =
  name: 'kissanime'

  http_options:
    follow_max: 5

  initialize: ->
    this.http_options.headers =
      'Cookie': ''
      'User-Agent': 'Ubuntu Chromium/34.0.1847.116 Chrome/34.0.1847.116 Safari/537.36'

    new Promise (resolve, reject) =>
      cloudscraper.get 'http://kissanime.to', (err, resp, body) =>
        if (err)
          reject(err)
        else
          cookie_string = resp.request.headers.cookie
          this.http_options.headers.cookie = cookie_string
          resolve()

  search:
    page: (query) ->
      data = { animeName: query, genres: '', status: '' }
      needle.postAsync('https://kissanime.to/AdvanceSearch', data, this.http_options).get('body')

    list: '.listing tr > td > a'
    row:
      name: (el) ->
        el.text().trim()
      url: (el) ->
        "https://kissanime.to" + el.attr('href')

  series:
    list: '.listing tr > td > a'
    row:
      name: (el) ->
        el.text().trim()
      url: (el) ->
        "https://kissanime.to" + el.attr('href')

  episode: ($, body) ->
    $('#selectQuality > option').map (index)  ->
      name = $(this).text()
      url = $(this).attr('value')
      buf = new Buffer(url, 'base64')
      url = buf.toString('utf-8')
      return {label: name, url: url}
    .get()
