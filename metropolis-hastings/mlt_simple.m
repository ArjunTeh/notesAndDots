% mlt script

% unanswered questions:
%   What's the right policy for saving a query? Right now I add when
%   a new state is accepted. Is there a better way to do it?

src_img = im2double(imread('cameraman.tif'));
dims = size(src_img);

tar_img = zeros(dims);

figure;
subplot(1,2,1); imshow(src_img); title('source');
subplot(1,2,2); imshow(tar_img); title('sampled');
drawnow;

x = 3*dims(2)/4;
y = 3*dims(1)/4;

max_iters = dims(1)*dims(2)*20;
num_rejects = 0;
for i=1:max_iters

    val = src_img(y, x);

    % pick a new random place using normal distribution
    % the s.d. is based on the brightness here
    sigma = 20;
    sig_f = sigma;
%     sig_f = sigma*(1/(1+2*val));
    
    xt = x + fix(normrnd(0, sig_f));
    yt = y + fix(normrnd(0, sig_f));
    while(xt<1 || xt>dims(2) || yt<1 || yt>dims(1))
        xt = x + fix(normrnd(0, sig_f));
        yt = y + fix(normrnd(0, sig_f));
    end

    val_t = src_img(yt, xt);
    sig_b = sigma;
%     sig_b = sigma*(1/(1+2*val_t));
    
    % decide to accept or reject
    p_forward = normpdf(xt, x, sig_f)*normpdf(yt, y, sig_f);
    p_backward = normpdf(x, xt,sig_b)*normpdf(y, yt, sig_b);
    
    % multiply by the function values
    c = (p_forward / p_backward) * (val_t / val);
    c = min(1, c);
    
    if (rand() <= c)
        x = xt;
        y = yt;
    else
        num_rejects = num_rejects + 1;        
    end

    tar_img(y, x) = tar_img(y,x) + 1;
    if mod(i,300)==0
        imshow(tar_img, []);
        drawnow;
    end
end

reject_ratio = num_rejects/max_iters;
fprintf("rejected: %i\n", num_rejects);
imshow(tar_img, []); 
title(strcat('rejection ratio: ', num2str(reject_ratio)));