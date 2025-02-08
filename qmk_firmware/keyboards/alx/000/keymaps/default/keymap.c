// Copyright 2023 QMK
// SPDX-License-Identifier: GPL-2.0-or-later

#include QMK_KEYBOARD_H

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
    [0] = LAYOUT_numpad_4x5(
        TG(1),   TG(2),
        KC_P7,   KC_P8,   KC_P9,   KC_PSLS,
        KC_P4,   KC_P5,   KC_P6,   KC_PAST,
        KC_P1,   KC_P2,   KC_P3,   KC_PPLS,
        KC_PENT, KC_P0,   KC_PDOT, KC_PMNS
    ),

    /*
     * ┌───┬───┬───┬───┐
     * │TG1│ / │ * │ - │
     * ┌───┬───┬───┐───┤
     * │Hom│ ↑ │PgU│   │
     * ├───┼───┼───┤ + │
     * │ ← │   │ → │   │
     * ├───┼───┼───┤───┤
     * │End│ ↓ │PgD│   │
     * ├───┴───┼───┤Ent│
     * │Insert │Del│   │
     * └───────┴───┘───┘
     */
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
    [1] = LAYOUT_numpad_4x5(
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
    [2] = LAYOUT_numpad_4x5(
        _______, _______,
        KC_HOME, KC_UP,   KC_PGUP, _______,
        KC_LEFT, XXXXXXX, KC_RGHT, _______,
        KC_END,  KC_DOWN, KC_PGDN, _______,
        KC_NUM,  KC_INS,  KC_DEL,  _______
    )
};
