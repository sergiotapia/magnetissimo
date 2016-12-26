import 'phoenix_html'
// import { Socket } from 'phoenix'
import React, { Component } from 'react'
import { render } from 'react-dom'

alert('webpack compiled me.');

class ExampleComponent extends Component {
  render () {
    return <div>Hello!</div>
  }
}

render(<ExampleComponent />, document.getElementyById('react-mount'))
