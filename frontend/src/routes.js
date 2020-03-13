import Choose   from './components/Choose.vue'
import Start    from './components/Start.vue'

const routes = [
    { path: '/',        component: Choose,  name: 'choose' },
    { path: '/start',   component: Start,   name: 'start' }
];

export default routes;
