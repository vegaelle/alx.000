// Copyright 2023 QMK
// SPDX-License-Identifier: GPL-2.0-or-later

#include QMK_KEYBOARD_H
#include <ws2812.h>

#define _MAIN 0
#define _NAV 1
#define _MOUSE 2

void keyboard_post_init_user(void) {
    gpio_set_pin_output(GP11);
    gpio_write_pin_high(GP11);
    rgblight_setrgb_at (0x00,  0x00, 0x50, 0);
}

layer_state_t layer_state_set_user(layer_state_t state) {
    switch (get_highest_layer(state)) {
    case _MAIN:
        rgblight_setrgb_at (0x00,  0x00, 0x50, 0);
        break;
    case _NAV:
        rgblight_setrgb_at (0x50,  0x00, 0x00, 0);
        break;
    case _MOUSE:
        rgblight_setrgb_at (0x00,  0x50, 0x00, 0);
        break;
    default: //  for any other layers
        rgblight_setrgb_at (0x00,  0x50, 0x50, 0);
        break;
    }
  return state;
}

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    /*
     *        ┌───┬───┐
     *        │TG1│TG2│
     *        └───┴───┘ 
     * ┌───┬───┬───┐ ┌───┐
     * │ 7 │ 8 │ 9 │ │ / │
     * ├───┼───┼───┤ ├───┤
     * │ 4 │ 5 │ 6 │ │ * │
     * ├───┼───┼───┤ ├───┤
     * │ 1 │ 2 │ 3 │ │ - │
     * ├───┼───┼───┤ ├───┤
     * │Ent│ 0 │ . │ │ + │
     * └───┴───┴───┘ └───┘
     */
    [_MAIN] = LAYOUT_numpad_4x5(
        TG(1),   TG(2),
        KC_P7,   KC_P8,   KC_P9,   KC_PSLS,
        KC_P4,   KC_P5,   KC_P6,   KC_PAST,
        KC_P1,   KC_P2,   KC_P3,   KC_PPLS,
        KC_PENT, KC_P0,   KC_PDOT, KC_PMNS
    ),

    /*
     *        ┌───┬───┐
     *        │TG1│TG2│
     *        └───┴───┘ 
     * ┌───┬───┬───┐ ┌───┐
     * │Hom│ ↑ │PgU│ │ , │
     * ├───┼───┼───┤ ├───┤
     * │ ← │   │ → │ │ = │
     * ├───┼───┼───┤ ├───┤
     * │End│ ↓ │PgD│ │ ? │
     * ├───┼───┼───┤ ├───┤
     * │Bsp│Ins│Del│ │ ? │
     * └───┴───┴───┘ └───┘
     */
    [_NAV] = LAYOUT_numpad_4x5(
        _______, _______,
        KC_HOME, KC_UP,   KC_PGUP, KC_PCMM,
        KC_LEFT, XXXXXXX, KC_RGHT, KC_PEQL,
        KC_END,  KC_DOWN, KC_PGDN, _______,
        KC_BSPC, KC_INS,  KC_DEL,  _______
    ),

    /*
     *        ┌───┬───┐
     *        │TG1│TG2│
     *        └───┴───┘ 
     * ┌───┬───┬───┐ ┌───┐
     * │ 7 │ 8 │ 9 │ │ / │
     * ├───┼───┼───┤ ├───┤
     * │ 4 │ 5 │ 6 │ │ * │
     * ├───┼───┼───┤ ├───┤
     * │ 1 │ 2 │ 3 │ │ - │
     * ├───┼───┼───┤ ├───┤
     * │ENT│ 0 │ . │ │ + │
     * └───┴───┴───┘ └───┘
     */
    [_MOUSE] = LAYOUT_numpad_4x5(
        _______, _______,
        KC_HOME, KC_UP,   KC_PGUP, _______,
        KC_LEFT, XXXXXXX, KC_RGHT, _______,
        KC_END,  KC_DOWN, KC_PGDN, _______,
        KC_NUM,  KC_INS,  KC_DEL,  _______
    )
};
