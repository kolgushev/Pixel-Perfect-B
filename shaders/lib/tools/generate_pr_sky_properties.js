import fs from 'fs'
import { eToNumber } from './lib/toStringParseable.js'

const sunThetaFn = "sunTheta"
const turbidityFn = "(turbidity + 1.0)"

const pFn = ["A", "B", "C", "D", "E"]

const perezCoeffs = [
    [-0.0193, -0.0167, 0.1787, -0.2592, -0.2608, -1.463],
    [-0.0665, -0.095, -0.3554, 0.0008, 0.0092, 0.4275],
    [-0.0004, -0.0079, -0.0227, 0.2125, 0.2102, 5.3251],
    [-0.0641, -0.0441, 0.1206, -0.8989, -1.6537, -2.5771],
    [-0.0033, -0.0109, -0.067, 0.0452, 0.0529, 0.3703],
]

const zenithChromacityCoeffs = [
    [
        [0.00166, -0.00375, 0.00209, 0],
        [-0.02903, 0.06377, -0.03202, 0.00394],
        [0.11693, -0.21196, 0.06052, 0.25886]
    ],
    [
        [0.00275, -0.00610, 0.00317, 0],
        [-0.04214, 0.08970, -0.04153, 0.00516],
        [0.15346, -0.26756, 0.06670, 0.26688]
    ]
]

for (let i = 0; i < zenithChromacityCoeffs.length; i++) {
    for (let j = 0; j < zenithChromacityCoeffs[i].length; j++) {
        for (let k = 0; k < zenithChromacityCoeffs[i][j].length; k++) {
            zenithChromacityCoeffs[i][j][k] = eToNumber(zenithChromacityCoeffs[i][j][k]);
            if (!String(zenithChromacityCoeffs[i][j][k]).includes('.')) {
                zenithChromacityCoeffs[i][j][k] += '.0';
            }
        }
    }
}


for (const [x, row] of perezCoeffs.entries()) {
    for (const [y, coeff] of row.entries()) {
        let stringified = eToNumber(coeff);
        if (!stringified.includes('.')) {
            stringified += '.0';
        }
        perezCoeffs[x][y] = stringified;
    }
}


const finalVars = []
const regex = []

finalVars.push(`variable.float.sunThetaSquared=${sunThetaFn} * ${sunThetaFn}`)
regex.push(RegExp(`variable\\.float\\.sunThetaSquared=`))
finalVars.push(`variable.float.sunThetaCubed=sunThetaSquared * ${sunThetaFn}`)
regex.push(RegExp(`variable\\.float\\.sunThetaCubed=`))
finalVars.push(`variable.float.turbiditySquared=${turbidityFn} * ${turbidityFn}`)
regex.push(RegExp(`variable\\.float\\.turbiditySquared=`))

const dot = (a, b) => {
    let str = '('

    for (let i = 0; i < a.length; i++) {
        str += `(${a[i]}) * (${b[i]}) + `
    }

    return str.slice(0, str.length - 3) + ')'
}

const thetaV = [
    'sunThetaCubed',
    'sunThetaSquared',
    sunThetaFn,
    '1.0',
]

const zenithChromacity = (a, b, c) => dot(['turbiditySquared', turbidityFn, '1.0'], [dot(thetaV, a), dot(thetaV, b), dot(thetaV, c)])

const zenithLuminance = () => {
    const chi = `((4.0 / 9.0 - ${turbidityFn} / 120.0) * (pi - 2.0 * ${sunThetaFn}))`

    return `((4.0453 * ${turbidityFn} - 4.971) * tan(${chi}) - 0.2155 * ${turbidityFn} + 2.4192)`
}

const perez = (gamma, A, B, C, D, E) => {
    return `((1.0 + (${A}) * exp(${B})) * (1.0 + (${C}) * exp((${D}) * (${gamma})) + (${E}) * cos(${gamma}) * cos(${gamma})))`
}

for (const [id, letter] of pFn.entries()) {
    for (const [channelId, channel] of ['x', 'y', 'Y'].entries()) {
        const name = `p_${channel}_${letter}`
        finalVars.push(`variable.float.${name}=(${perezCoeffs[id][channelId]}) * (${turbidityFn}) + (${perezCoeffs[id][channelId + 3]})`)
        regex.push(RegExp(`variable\\.float\\.${name}=`))
    }
}

for (const [id, channel] of ['x', 'y'].entries()) {
    const name = `p_${channel}_Z`
    finalVars.push(`variable.float.${name}=(${zenithChromacity(zenithChromacityCoeffs[id][0], zenithChromacityCoeffs[id][1], zenithChromacityCoeffs[id][2])}) / (${perez(sunThetaFn, `p_${channel}_A`, `p_${channel}_B`, `p_${channel}_C`, `p_${channel}_D`, `p_${channel}_E`)})`)
    regex.push(RegExp(`variable\\.float\\.${name}=`))
}

finalVars.push(`variable.float.p_Y_Z=(${zenithLuminance()}) * 1000.0 / (${perez(sunThetaFn, 'p_Y_A', 'p_Y_B', 'p_Y_C', 'p_Y_D', 'p_Y_E')})`)
regex.push(RegExp(`variable\\.float\\.p_Y_Z=`))

pFn.push('Z')

for (const letter of pFn) {
    finalVars.push(`uniform.vec3.p_${letter}=vec3(p_x_${letter}, p_y_${letter}, p_Y_${letter})`)
    regex.push(RegExp(`uniform\\.vec3\\.p_${letter}=`))
}

const targetFilePath = "../../shaders.properties"

const fileContent = fs.readFileSync(targetFilePath, "utf8")
const lines = fileContent.split("\n")
const used = []
const append = []

for (let i = 0; i < lines.length; i++) {
    for (let j = 0; j < regex.length; j++) {
        if (regex[j].test(lines[i])) {
            lines[i] = finalVars[j]
            used.push(finalVars[j])
        }
    }
}

for (const item of finalVars) {
    const index = used.indexOf(item)
    if (index == -1) {
        append.push(item)
    }
}

fs.writeFileSync(targetFilePath, lines.concat(...append).join("\n"))
