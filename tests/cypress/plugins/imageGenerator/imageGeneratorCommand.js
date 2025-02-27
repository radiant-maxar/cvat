// Copyright (C) 2020-2022 Intel Corporation
//
// SPDX-License-Identifier: MIT

Cypress.Commands.add('imageGenerator', (directory, fileName, width, height, color, posX, posY, message, count, extension = 'png') => cy.task('imageGenerator', {
    directory,
    fileName,
    width,
    height,
    color,
    posX,
    posY,
    message,
    count,
    extension,
}));

Cypress.Commands.add('bufferToImage', (directory, fileName, extension = 'png', buffer = null) => cy.task('bufferToImage', {
    directory,
    fileName,
    extension,
    buffer,
}));
