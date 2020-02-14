new Vue({
    el: '#redeliste',
    data() { return {
        role: null,
        session: null,
        nextSpeakerIds: [],
        listOpen: false,
        personId: null,
        wsConnected: false,
        wsURL: null,
    }},
    computed: {
        persons() {
            return [...this.session.persons].sort((a, b) => {
                let an = a.name.toUpperCase();
                let bn = b.name.toUpperCase();
                return an < bn ? -1 : an == bn ? 0 : 1;
            });
        },
        nextSpeakers() {
            return this.nextSpeakerIds.map(id => this.session.persons[id]);
        },
        isOnSpeakersList() {
            return this.nextSpeakerIds.includes(this.personId);
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
                let data            = JSON.parse(msg.data);
                this.session        = data.session;
                this.nextSpeakerIds = data.nextSpeakers;
                this.listOpen       = data.listOpen;
            };
            this.socket.onclose = () => {
                window.location.replace('/bye');
            };
        },
        disconnect(confirmText) {
            if (confirm(confirmText)) {
                this.socket.close();
                this.wsConnected = false;
                this.session     = null;
                window.location.replace('/bye');
            }
        },
        requestSpeak() {
            this.socket.send('RQSP');
        },
        revoke() {
            this.socket.send('REVK');
        },
        callSpeaker() {
            this.socket.send('NEXT');
        },
        overrideSpeaker(id) {
            this.socket.send('NEXT ' + id);
        },
        closeList() {
            this.socket.send('CLOSELIST');
        },
        openList() {
            this.socket.send('OPENLIST');
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
    mounted() {

        // Collect data: local
        let isAdmin     = JSON.parse(sessionStorage.getItem('isAdmin'));
        this.personId   = parseInt(sessionStorage.getItem('personId'));
        this.role       = isAdmin ? 'chair' : 'user';

        // Collect data: remote
        axios.get('/session/' + sessionStorage.getItem('token')).then(res => {
            this.session = res.data.session;

            // Construct websocket URL
            this.wsURL = res.data.wsURL
                + '?personId=' + encodeURIComponent(this.personId);
            if (isAdmin) {
                this.wsURL += '&adminToken='
                + encodeURIComponent(sessionStorage.getItem('adminToken'))
            }

            // Show session token at the top
            document.getElementById('token').textContent = this.session.token;

            // Start websocket synchronisation
            this.connect();
        });
    },
})
