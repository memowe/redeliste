new Vue({
    el: '#redeliste',
    data() { return {
        role: null,
        session: null,
        nextSpeakerIds: [],
        userId: null,
        wsConnected: false,
        wsURL: null,
    }},
    computed: {
        nextSpeakers() {
            return this.nextSpeakerIds.map(id => this.session.persons[id]);
        },
        isOnSpeakersList() {
            return this.nextSpeakerIds.includes(this.userId);
        },
    },
    methods: {
        connect() {
            if (! this.wsURL) return;
            this.socket = new WebSocket(this.wsURL);
            this.socket.onopen = () => {
                this.wsConnected = true;
            };
            this.socket.onmessage = msg => {
                let data = JSON.parse(msg.data);
                this.session = data.session;
                this.nextSpeakerIds = data.nextSpeakers;
            };
            this.socket.onclose = () => {
                window.location.replace('/bye');
            };
        },
        disconnect() {
            this.socket.close();
            this.wsConnected = false;
            this.session     = null;
        },
        requestSpeak() {
            this.socket.send('RQSP');
        },
        callSpeaker() {
            this.socket.send('NEXT');
        },
        clearItem(confirmText) {
            if (confirm(confirmText)) {
                this.socket.send('NEXTITEM');
            }
        },
        closeSession(confirmText) {
            if (confirm(confirmText)) {
                this.socket.send('CLOSESESSION');
            }
        },
    },
    beforeMount() {
        this.role = this.$el.attributes['data-role'].value;
    },
    mounted() {
        axios.get('/data.json').then(res => {
            this.session = res.data.session;
            this.userId  = res.data.userId;
            this.wsURL   = res.data.wsURL;
            this.connect();
        });
    },
})
