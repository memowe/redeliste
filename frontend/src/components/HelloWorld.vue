<template>
    <p>{{ answer }}</p>
</template>

<script>
export default {
    name: 'HelloWorld',
    props: {
        answer: String
    }
}
</script>

<style scoped>
p {
    font-weight: bold;
}
</style>
