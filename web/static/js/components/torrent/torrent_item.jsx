import React, { Component } from 'react'

export default class TorrentItem extends Component {
  constructor (props) {
    super(props)
  }

  render () {
    return (
      <p>This is a torrent. {this.props.name}.</p>
    )
  }
}
