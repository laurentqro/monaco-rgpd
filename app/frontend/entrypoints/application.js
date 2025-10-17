import { createInertiaApp } from '@inertiajs/svelte'
import { mount } from 'svelte'
import '../styles/application.css'

createInertiaApp({
  resolve: name => {
    const pages = import.meta.glob('../pages/**/*.svelte', { eager: true })
    const component = pages[`../pages/${name}.svelte`]
    return component?.default || component
  },
  setup({ el, App, props }) {
    mount(App, { target: el, props })
  },
})
