import 'phoenix_html'
// import { Socket } from 'phoenix'
import React, { Component } from 'react'
import { render } from 'react-dom'
import TorrentItem from 'components/torrent/torrent_item.jsx'

class ExampleComponent extends Component {
  render () {
    return (
      <div>
        <TorrentItem name='Foobar' />
        <TorrentItem name='Bar Baz' />
        <TorrentItem name='Example' />
      </div>
    )
  }
}

render(<ExampleComponent />, document.getElementById('react-mount'))
