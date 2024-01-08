window.onload = function () {


    let isPlaying = false;
    let pinsCompleted = [];
    let dragX, dragY;
    const pins = document.querySelectorAll('.playarea ul li');
    const stick = document.querySelector('#stick');
    const playarea = document.querySelector('.playarea');
    const playarea_box = playarea.getBoundingClientRect();

    function ResetLockpickGame() {
        if (timeout) { clearTimeout(timeout); timeout = false; }
        if (interval) { clearInterval(interval); interval = false; }

        pinsCompleted = [];
        isPlaying = false;

        document.body.style.opacity = 0;
        document.querySelector('section[for="lockpick"]').style.opacity = 0;

        stick.style.top = '65%';
        stick.style.left = '31.5%';

        pins.forEach(elem => {
            let min = 100, max = 180;
            let randomHeight = Math.ceil(Math.random() * (max - min) + min);
            elem.style.setProperty('--pin-height', `${randomHeight}px`);

            elem.setAttribute('data-finished', 'false');
            elem.style.setProperty('--pin-game-color', 'transparent');
            elem.style.setProperty('--pin-top', '0px');
        });
    }

    let timeout = false, interval = false;
    document.body.addEventListener('mousemove', function (e) {
        if (isPlaying == 'lockpick') {
            // Stick Drag
            dragX = e.clientX;
            dragY = e.clientY;

            if (dragY > playarea_box.top && dragY < playarea_box.top + playarea.clientHeight - stick.clientHeight
                && dragX > playarea_box.left && dragX < playarea_box.left + playarea.clientWidth) {
                stick.style.top = `${dragY}px`;
                stick.style.left = `${dragX - stick.clientWidth}px`;

                // Pins
                pins.forEach(function (elem) {
                    if (elem.getAttribute('data-finished') != 'true') {
                        const box = elem.getBoundingClientRect();
                        const top = window.innerHeight - dragY - playarea_box.top - 12;
                        let pinHeight = elem.querySelector('span').clientHeight;
                        let maxTop = 375 - 100 - 12 - pinHeight;

                        if (top > 0 && dragX > box.left) {
                            elem.style.setProperty('--pin-transition', '0s');
                            if (dragX > box.left + elem.clientWidth + 20) {
                                if (top > 25 && top < maxTop + 25) {
                                    elem.style.setProperty('--pin-top', `${top - 25}px`);
                                }
                            } else if (top < maxTop) {
                                elem.style.setProperty('--pin-top', `${top}px`);
                            }
                        } else {
                            elem.style.setProperty('--pin-transition', '.1s');
                            elem.style.setProperty('--pin-top', `0px`);
                        }

                        let click = 200 - pinHeight;
                        let finished = elem.getAttribute('data-finished');
                        let pinTop = parseInt(elem.style.getPropertyValue('--pin-top'));
                        let accurate = 5;
                        if (finished != 'ready' && pinTop > click - accurate && pinTop < click + accurate) {
                            elem.setAttribute('data-finished', 'ready');
                        } else if (finished == 'ready') {
                            elem.setAttribute('data-finished', 'false');
                        }
                    }
                });
            }
        }
    });

    const timer = document.querySelector('section[for="lockpick"] .timer');
    function StartLockpicking(seconds, translate) {
        if (!Number(seconds) || isPlaying) { return; }
        ResetLockpickGame();

        isPlaying = 'lockpick';
        document.body.style.opacity = 1;
        document.querySelector('section[for="lockpick"]').style.opacity = 1;

        timer.style.display = 'none';
        timer.offsetLeft;
        timer.querySelector('h1').innerText = translate['minigame_ready'] || 'Get Ready';
        timer.style.display = 'block';

        let previewTime = 3;
        interval = setInterval(function () {
            timer.style.display = 'none';
            timer.offsetLeft;
            timer.querySelector('h1').innerText = previewTime;
            timer.style.display = 'block';

            PlayAudio('./sound/countdown.wav');

            if (previewTime <= 0) {
                clearInterval(interval);

                timer.style.display = 'none';
                timer.offsetLeft;
                timer.querySelector('h1').innerText = translate['minigame_start'] || 'Game started!';
                timer.style.display = 'block';

                PlayAudio('./sound/startgame.wav');

                pins.forEach(elem => {
                    if (elem.getAttribute('data-finished') != 'true') {
                        elem.style.setProperty('--pin-game-color', 'transparent');
                    }
                });
                let pin = pins[Math.floor(Math.random() * pins.length)];
                pin.style.setProperty('--pin-game-color', 'red');

                timeout = setTimeout(function () {
                    timer.style.display = 'none';
                    timer.offsetLeft;
                    timer.querySelector('h1').innerText = seconds;
                    timer.style.display = 'block';

                    interval = setInterval(function () {
                        seconds--;

                        timer.style.display = 'none';
                        timer.offsetLeft;

                        let label = seconds;
                        if (seconds <= 0 || pinsCompleted.length == pins.length) {
                            clearInterval(interval);

                            timer.style.animationDuration = '3s';
                            let win = false;
                            if (pinsCompleted.length == pins.length) {
                                label = translate['minigame_success'] || 'You succeed';
                                win = true;
                            } else {
                                label = translate['minigame_failed'] || 'You failed';
                            }

                            timer.querySelector('h1').innerText = label;
                            timer.style.display = 'block';
                            isPlaying = false;

                            timeout = setTimeout(function () {
                                fetch(`https://${GetParentResourceName()}/lockpick`, {
                                    method: 'POST',
                                    body: JSON.stringify({
                                        win: win
                                    })
                                }).catch(function () { });
                                ResetLockpickGame();
                            }, 1000);
                            return;
                        }

                        timer.querySelector('h1').innerText = label;
                        timer.style.display = 'block';

                        pins.forEach(elem => {
                            if (elem.getAttribute('data-finished') == 'ready') {
                                pinsCompleted.push(elem);
                                elem.style.setProperty('--pin-game-color', 'lime');
                                elem.setAttribute('data-finished', 'true');

                                fetch(`https://${GetParentResourceName()}/PlaySound`).catch(function () { });
                            } else if (elem.getAttribute('data-finished') != 'true') {
                                elem.style.setProperty('--pin-game-color', 'transparent');
                            }
                        });

                        let unlockedPins = document.querySelectorAll('section[for="lockpick"] ul li[data-finished="false"]');
                        if (unlockedPins.length > 0) {
                            let pin = unlockedPins[Math.floor(Math.random() * unlockedPins.length)];
                            pin.style.setProperty('--pin-game-color', 'red');
                        }
                    }, 1000);
                }, 1000);
            }

            previewTime--;
        }, 1000);
    }

    let exitButton = false;
    window.addEventListener('message', function (e) {
        if (e.data.lockpick) {
            if (e.data.exitButton) {
                exitButton = e.data.exitButton;
            }
            StartLockpicking(e.data.lockpick || 10, e.data.translate);
        }
    });

    document.onkeyup = function (e) {
        if (e.key == 'Escape' || exitButton && e.key.toLowerCase() == exitButton.toLowerCase()) {
            if (isPlaying == 'lockpick') {
                ResetLockpickGame();
                fetch(`https://${GetParentResourceName()}/close`).catch(function () { });
            }
        }
    }

    function PlayAudio(source) {
        let audio = new Audio();
        audio.src = source;
        audio.volume = 0.1;
        audio.play();

        audio.onended = function (e) {
            audio.remove();
        }
        audio.onerror = function (e) {
            audio.remove();
        }
    }
}