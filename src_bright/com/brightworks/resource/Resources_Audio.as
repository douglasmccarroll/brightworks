package com.brightworks.resource
{
    import mx.core.SoundAsset;

    public class Resources_Audio
    {
        [Embed('/assets/audio/chirps.mp3')]
        private static const _CHIRPS:Class;
        public static const CHIRPS:SoundAsset = new _CHIRPS(); // 6 chirps in 3 seconds - for experimenting with audio
        [Embed('/assets/audio/buzz_thud.mp3')]
        private static const _FAIL_THUD:Class;
        public static const FAIL_THUD:SoundAsset = new _FAIL_THUD();
        [Embed('/assets/audio/click.mp3')]
        private static const _CLICK:Class;
        public static const CLICK:SoundAsset = new _CLICK();
        [Embed('/assets/audio/pluck_high.mp3')]
        private static const _PLUCK_HIGH:Class;
        public static const PLUCK_HIGH:SoundAsset = new _PLUCK_HIGH();
        [Embed('/assets/audio/silence_half_second.mp3')]
        private static const _SILENCE_HALF_SECOND:Class;
        public static const SILENCE_HALF_SECOND:SoundAsset = new _SILENCE_HALF_SECOND();
    }
}
