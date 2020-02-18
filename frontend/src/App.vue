<template>
    <div id="app">
        <HelloWorld v-bind:answer="answer" />
    </div>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue'
import axios from 'axios'

export default {
    name: 'App',
    data: function() { return {
        answer: 'loading...'
    } },
    components: {
        HelloWorld
    },
    mounted () {
        axios.get('http://localhost:3000/answer').then(res => {
            this.answer = res.data.answer.toString();
        });
    }
}
</script>

<style>
#app {
    color: maroon;
}
</style>
