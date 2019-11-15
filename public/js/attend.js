new Vue({
    el: '#attend',
    data() { return {
        session: null,
        userId: null,
        wsConnected: false,
        wsURL: null,
    }},
    methods: {
        connect() {
            if (! this.wsURL) return;
            this.socket = new WebSocket(this.wsURL);
            this.socket.onopen = () => {
                this.wsConnected = true;
            };
            this.socket.onmessage = msg => {
                this.session = JSON.parse(msg.data).session;
            };
        },
        disconnect() {
            this.socket.close();
            this.wsConnected = false;
            this.session     = null;
        },
        requestSpeak() {
            this.socket.send('RQSP');
        }
    },
    mounted() {
        axios.get('/data.json').then(res => {
            this.session = res.data.session;
            this.userId  = res.data.userId;
            this.wsURL   = res.data.wsURL;
            this.connect();
        });
    }
})
