function sortedImagNames = ReadSortImagFiles(dirname)

    imgNames=dir(fullfile(dirname,'*.jpg'));
    imgNames={imgNames.name}';
    imgStrings=regexp([imgNames{:}],'(\d*)','match');
    imgNumbers=str2double(imgStrings);
    [~,sortedIndices]=sort(imgNumbers);
    sortedImagNames=imgNames(sortedIndices);

end