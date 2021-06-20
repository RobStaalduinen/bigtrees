export function objectOptionList(options, additionalOptions = []) {
  let parsedOptions = options.map(option => {
    return { value: option.id, text: option.name }
  })

  return parsedOptions.concat(additionalOptions);
}

export function stringOptionList(options, additionalOptions = []) {
  let parsedOptions =  options.map(option => {
    return {
      value: option,
      text: option.charAt(0).toUpperCase() + option.slice(1)
    }
  })

  return parsedOptions.concat(additionalOptions);
}
